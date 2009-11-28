# -*- coding: utf-8 -*-
require "command/app"
require "configuration-updator"
require "lucie/logger/updator"
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
        if @global_options.ldb_repository
          @configurator = Configurator.new( @global_options.source_control || "Mercurial", @debug_options )
          if FileTest.directory?( Configurator::Server.clone_directory( @global_options.ldb_repository ) )
            @configurator.update_server @global_options.ldb_repository
          else
            @configurator.clone_to_server @global_options.ldb_repository, Lucie::Server.ip_address_for( nodes )
          end
          nodes.collect do | each |
            Thread.start( each, Lucie::Server.ip_address_for( nodes ) ) do | node, lucie_ip |
              @configurator.clone_to_client @global_options.ldb_repository, node, lucie_ip
            end
          end.each do | each |
            each.join
          end
        end
        @updator = ConfigurationUpdator.new( @debug_options )
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
          @updator.start node, Lucie::Logger::Updator.new
        end
      end


      def nodes_from node_names
        node_names.collect do | each |
          node_from each
        end
      end


      def node_from name
        opts = { :ip_address => Network.resolve( name, @debug_options ),
          :netmask_address => Network.netmask_address( name, @debug_options ) }
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
