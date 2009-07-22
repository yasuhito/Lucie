require "command/app"
require "ldb"
require "network"
require "network_interfaces"
require "node"
require "nodes"
require "resolv"
require "thread"


module Command
  module NodeUpdate
    class App < Command::App
      def initialize argv = ARGV, messenger = nil, nic = nil
        super argv, messenger
        @nic = nic
        @ldb = LDB.new( debug_options, @messenger, nic )
      end


      def main node_names
        nodes = load_nodes( node_names )
        @ldb.update_local_ldb_repository nodes.first, Lucie::Log
        nodes.collect do | each |
          create_update_thread_for each 
        end.each do | each |
          each.join
        end
      end


      ##########################################################################
      private
      ##########################################################################


      def create_update_thread_for node
        Thread.start do
          @ldb.update node, Lucie::Log
          @ldb.start node, Lucie::Log
        end
      end


      def load_nodes node_names
        node_names.collect do | each |
          load_node each
        end
      end


      def load_node name
        Node.new name, { :ip_address => resolve( name ), :netmask_address => netmask_for( name ) }
      end


      def resolve name
        if Nodes.find( name ) and @options.dry_run
          Nodes.find( name ).ip_address
        else
          begin
            Resolv.getaddress( name ) rescue raise( "no address for #{ name }" )
          end
        end
      end


      def netmask_for name
        raise "cannot find network interface for #{ name }" if nic_for( name ).empty?
        nic_for( name ).first.netmask
      end


      def nic_for name
        all_nic.select do | each |
          Network.network_address( resolve( name ), each.netmask ) == each.subnet
        end
      end


      def all_nic
        @nic || NetworkInterfaces
      end
    end
  end
end
