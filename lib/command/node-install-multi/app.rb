require "command/app"
require "command/node-install-multi/parser"
require "configurator"
require "node"
require "nodes"


module Command
  module NodeInstallMulti
    class App < Command::App
      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options
      end


      def main
        prepare_installation
        install
      end


      ##########################################################################
      private
      ##########################################################################


      def prepare_installation
        begin
          parse
          generate_ssh_keypair
          update_sudo_timestamp
          start_main_logger
          check_prerequisites
          create_nodes
          start_secret_server
          setup_ldb
          create_installer
          start_html_logger
          start_super_reboot
          setup_ssh
          setup_first_stage
        rescue
          Nodes.load_all.each do | each |
            if each.status.nil? or each.status.incomplete?
              @html_logger.update_status( each, "failed" ) if @html_logger
            end
          end
          raise $!
        end
      end


      def install
        begin
          install_parallel
        rescue
          @tp.killall
          Nodes.load_all.each do | each |
            if each.status.nil? or each.status.incomplete?
              @html_logger.update_status( each, "failed" ) if @html_logger
            end
          end
          raise $!
        end
      end


      def start_installer_for node, logger
        server_clone_directory = @global_options.ldb_repository ? Configurator::Server.clone_directory( @global_options.ldb_repository ) : nil
        @installer.start( node,
                          @node_options[ node.name ].suite,
                          @node_options[ node.name ].linux_image,
                          @node_options[ node.name ].storage_conf,
                          server_clone_directory,
                          logger,
                          @html_logger,
                          debug_options,
                          @debug_options[ :messenger ] )
      end


      def create_nodes
        @node_options.keys.each do | each |
          node = Node.new( each, node_options( each ) )
          Nodes.add node, debug_options, @debug_options[ :messenger ]
        end
      end


      def node_options name
        { :netmask_address => @node_options[ name ].netmask,
          :mac_address => @node_options[ name ].mac,
          :ip_address => @node_options[ name ].ip_address }
      end


      def parse
        @node_options = Command::NodeInstallMulti::Parser.new( @argv, @global_options ).parse
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
