require "command/app"
require "command/installer"
require "command/node-install-multi/parser"
require "configurator"
require "installation-tracker"
require "lucie/debug"
require "node"
require "nodes"
require "process-pool"


module Command
  module NodeInstallMulti
    class App < Command::App
      include Command::Installer
      include Lucie::Debug


      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options
        @global_options.check_mandatory_options
        @node_logger = {}
      end


      def main
        begin
          prepare_installation
          install
        ensure
          @installation_tracker.finalize if @installation_tracker
          if @global_options.secret
            Process.kill "TERM", Blocker::PidFile.recall( "confidential-data-server" )
          end
          Blocker.release "confidential-data-server"
        end
      end


      ##########################################################################
      private
      ##########################################################################


      def prepare_installation
        begin
          parse
          start_main_logger
          check_prerequisites
          maybe_generate_and_authorize_keypair
          update_sudo_timestamp
          register_nodes
          maybe_start_confidential_data_server
          maybe_setup_ldb
          create_installer
          start_html_logger
          setup_ssh_forward_agent
          setup_first_stage_environment
        rescue Exception
          Nodes.load_all.each do | each |
            disable_network_boot each
            each.status.fail! if each.status
          end
          raise $!
        end
      end


      def install
        process_pool = ProcessPool.new( @debug_options )
        begin
          Nodes.load_all.each do | each |
            sleep 1
            process_pool.dispatch( each ) do | each |
              begin
                $0 = "lucie: installer (#{ each.name })"
                logger = @node_logger[ each ]
                run_first_reboot each, logger
                run_first_stage each, logger
                run_second_reboot each, logger
                run_second_stage each, logger
                run_third_reboot each, logger
                info "Node '#{ each.name }' installed.\n"
                each.status.succeed!
              rescue Exception => e
                each.status.fail!
                $stderr.puts e.message
                logger.error e.message
                if @global_options.verbose
                  e.backtrace.each do | each |
                    $stderr.puts each
                    logger.debug each
                  end
                end
              end
            end
          end
          process_pool.shutdown
        rescue Exception => e
          process_pool.killall
          Nodes.load_all.each do | each |
            each.status.fail! if each.status.incomplete?
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
                          @global_options.break,
                          logger,
                          @debug_options,
                          @debug_options[ :messenger ] )
      end


      def register_nodes
        @node_options.keys.each do | each |
          node = Node.new( each, node_options( each ) )
          log_directory = Lucie::Logger::Installer.new_log_directory( node, @debug_options, @debug_options[ :messenger ] )
          logger = Lucie::Logger::Installer.new( log_directory, @debug_options )
          node.status = Status::Installer.new( log_directory, @debug_options )
          node.status.start!
          @node_logger[ node ] = logger
          Nodes.add node, @debug_options, @debug_options[ :messenger ]
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
