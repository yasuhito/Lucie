# -*- coding: utf-8 -*-
require "command/app"
require "configuration-updator"
require "network"
require "node"
require "thread"


module Command
  module NodeUpdate
    class App < Command::App
      # [FIXME] Command::App#initialize の引数を
      #         Command::App#initialize( argv, debug_options ) に修正し、
      #         この initialize メソッドを無くすべし
      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options
      end


      def main node_names
        start_secret_server
        nodes = nodes_from( node_names )
        if @options.ldb_repository
          @configurator = Configurator.new( @options.source_control || "Mercurial", debug_options )
          if FileTest.directory?( Configurator::Server.clone_directory( @options.ldb_repository ) )
            @configurator.update_server @options.ldb_repository
          else
            @configurator.clone_to_server @options.ldb_repository, Lucie::Server.ip_address_for( nodes )
          end
          nodes.collect do | each |
            Thread.start( each ) do node
              @configurator.clone_to_client @options.ldb_repository, node, Lucie::Server.ip_address_for( nodes )
            end
          end.each do | each |
            each.join
          end
        end
        @updator = ConfigurationUpdator.new( argv_options )
        update nodes
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
