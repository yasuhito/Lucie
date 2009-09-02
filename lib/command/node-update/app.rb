require "command/app"
require "configuration-updator"
require "network"
require "node"
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
        @updator = ConfigurationUpdator.new( argv_options )
        update nodes_from( node_names )
      end


      ##########################################################################
      private
      ##########################################################################


      def update nodes
        @updator.update_server_for nodes
        nodes.collect do | each |
          start_update_for each 
        end.each do | each |
          each.join
        end
      end


      def start_update_for node
        Thread.start do
          @updator.update_client node
          @updator.start node
        end
      end


      def nodes_from node_names
        node_names.collect do | each |
          node_from each
        end
      end


      def node_from name
        opts = { :ip_address => Network.resolve( name, argv_options ),
          :netmask_address => Network.netmask_address( name, argv_options ) }
        Node.new name, opts
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
