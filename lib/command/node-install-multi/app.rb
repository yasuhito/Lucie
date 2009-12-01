require "command/app"
require "command/installer"
require "command/node-install-multi/parser"
require "configurator"
require "node"
require "nodes"
require "thread_pool"


module Command
  module NodeInstallMulti
    class App < Command::App
      include Command::Installer


      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options
      end


      def main
        begin
          prepare_installation
          install
        ensure
          Process.kill( "TERM", @cds_pid ) if @cds_pid
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
          create_super_reboot
          setup_ssh_forward_agent
          setup_first_stage_environment
        rescue Exception
          disable_network_boot
          Nodes.load_all.each do | each |
            if each.status.nil? or each.status.incomplete?
              @html_logger.update_status( each, "failed" ) if @html_logger
            end
          end
          raise $!
        end
      end


      def install
        thread_pool = ThreadPool.new
        begin
          Nodes.load_all.collect do | each |
            thread_pool.dispatch( each ) do | each |
              sleep 1
              log_directory = Lucie::Logger::Installer.new_log_directory( each, @debug_options, @debug_options[ :messenger ] )
              logger = Lucie::Logger::Installer.new( log_directory, @debug_options )
              each.status = Status::Installer.new( log_directory, @debug_options, @debug_options[ :messenger ] )
              begin
                each.status.start!
                run_first_reboot each, logger
                run_first_stage each, logger
                run_second_reboot each, logger
                run_second_stage each, logger
                each.status.succeed!
                @html_logger.proceed_to_next_step each, "ok"
              rescue Exception => e
                each.status.fail!
                $stderr.puts e.message
                logger.error e.message
                @html_logger.update_status each, "failed (#{ e.message })"
                if @global_options.verbose
                  e.backtrace.each do | each |
                    $stderr.puts each
                    logger.debug each
                  end
                end
              end
            end
          end
          thread_pool.shutdown
        rescue Exception => e
          thread_pool.killall
          Nodes.load_all.each do | each |
            if each.status.nil? or each.status.incomplete?
              each.status.fail!
              emsg = e.message.empty? ? e.inspect : e.message
              @html_logger.update_status each, "failed (#{ emsg })"
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
                          @debug_options,
                          @debug_options[ :messenger ] )
      end


      def register_nodes
        @node_options.keys.each do | each |
          node = Node.new( each, node_options( each ) )
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
