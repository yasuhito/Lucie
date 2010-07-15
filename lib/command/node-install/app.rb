require "command/app"
require "command/installer"
require "confidential-data-server"
require "lucie/debug"
require "node"
require "nodes"


module Command
  module NodeInstall
    class App < Command::App
      include Command::Installer
      include Lucie::Debug


      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options
        @global_options.check_mandatory_options
        @global_options.check_mandatory_options
      end


      def main node_name
        begin
          prepare_installation node_name
          install
        ensure
          if @global_options.secret
            Process.kill "TERM", Blocker::PidFile.recall( "confidential-data-server" )
          end
          Blocker.release "confidential-data-server"
        end
      end


      ##########################################################################
      private
      ##########################################################################


      def prepare_installation node_name
        begin
          start_main_logger
          check_prerequisites
          maybe_generate_and_authorize_keypair
          update_sudo_timestamp
          register_node node_name
          maybe_start_confidential_data_server
          maybe_setup_ldb
          create_installer
          start_html_logger
          setup_ssh_forward_agent
          setup_first_stage_environment
        rescue Exception
          Nodes.load_all.each do | each |
            disable_network_boot each
          end
          raise $!
        end
      end


      def install
        begin
          Nodes.load_all.collect do | each |
            begin
              each.status.start!
              run_first_reboot each, @logger
              run_first_stage each, @logger
              run_second_reboot each, @logger
              run_second_stage each, @logger
              run_third_reboot each, @logger
              info "Node '#{ each.name }' installed.\n"
              each.status.succeed!
            rescue Exception => e
              each.status.fail!
              $stderr.puts e.message
              @logger.error e.message
              if @global_options.verbose
                e.backtrace.each do | each |
                  $stderr.puts each
                  @logger.debug each
                end
              end
            end
          end
        rescue Exception => e
          Nodes.load_all.each do | each |
            if each.status.nil? or each.status.incomplete?
              each.status.fail!
            end
          end
          raise $!
        end
      end


      def start_installer_for node, logger
        server_clone_directory = @global_options.ldb_repository ? Configurator::Server.clone_directory( @global_options.ldb_repository ) : nil
        @installer.start( node,
                          @global_options.suite,
                          @global_options.linux_image,
                          @global_options.storage_conf,
                          server_clone_directory,
                          false,
                          logger,
                          @debug_options,
                          @debug_options[ :messenger ] )
      end


      def register_node node_name
        node = Node.new( node_name, node_options )
        log_directory = Lucie::Logger::Installer.new_log_directory( node, @debug_options, @debug_options[ :messenger ] )
        @logger = Lucie::Logger::Installer.new( log_directory, @debug_options )
        node.status = Status::Installer.new( log_directory, @debug_options )
        Nodes.add node, @debug_options, @messenger
      end


      def node_options
        { :netmask_address => @global_options.netmask,
          :mac_address => @global_options.mac,
          :ip_address => @global_options.ip_address }
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
