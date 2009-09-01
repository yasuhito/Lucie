require "command/app"
require "configuration-updator"
require "network"
require "network_interfaces"
require "node"
require "nodes"
require "resolv"
require "thread"


module Command
  module NodeUpdate
    class App < Command::App
      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options[ :messenger ]
      end


      def main node_names
        start_secret_server
        nodes = load_nodes( node_names )
        @updator = ConfigurationUpdator.new( debug_options )
        @updator.update_server_for nodes
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
          @updator.update_client node
          @updator.start node
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
        if Nodes.find( name ) and debug_options[ :dry_run ]
          Nodes.find( name ).ip_address
        else
          Resolv.getaddress( name ) rescue raise( "no address for #{ name }" )
        end
      end


      def netmask_for name
        return "NETMASK" if debug_options[ :dry_run ]
        raise "cannot find network interface for #{ name }" unless nic_for( name )
        nic_for( name ).netmask
      end


      def nic_for name
        NetworkInterfaces.select do | each |
          Network.network_address( resolve( name ), each.netmask ) == each.subnet
        end.first
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
