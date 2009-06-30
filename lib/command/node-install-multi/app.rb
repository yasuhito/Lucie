require "command/app"
require "configuration"
require "environment"
require "installer"
require "installers"
require "ldb"
require "lucie/logger/html"
require "lucie/utils"
require "mandatory_option_error"
require "node"
require "nodes"
require "reboot-watch-dog"
require "ssh"
require "super-reboot"


module Command
  module NodeInstallMulti
    class App < Command::App
      include Lucie::Utils


      def initialize argv = ARGV, messenger = nil
        super argv, messenger
      end


      def main node_argv
        parse node_argv
        update_sudo_timestamp
        start_main_logger
        check_prerequisites
        create_nodes
        setup_ldb
        create_installer
        start_html_logger
        start_super_reboot
        setup_ssh
        setup_first_stage
        install_parallel
      end


      ##########################################################################
      private
      ##########################################################################


      def install_parallel
        threads = []
        begin
          Nodes.load_all.collect do | each |
            sleep 1
            log_directory = Lucie::Logger::Installer.new_log_directory( each, debug_options, @messenger )
            logger = Lucie::Logger::Installer.new( log_directory, @dry_run )
            each.status = Status::Installer.new( log_directory, debug_options, @messenger )
            create_installer_thread each, logger
          end.each do | each |
            each.join
          end
        rescue Interrupt
          $stderr.puts "Interrupted"
          Nodes.load_all.each do | each |
            each.status.fail!
            @html_logger.update each, "failed (interrupted)"
          end
        end
      end


      def create_installer_thread node, logger
        Thread.start do
          begin
            node.status.start!
            run_first_stage node, logger
            run_second_stage node, logger
            node.status.succeed!
          rescue => e
            node.status.fail!
            $stderr.puts e.message
            logger.error e.message
            @html_logger.update node, "failed (#{ e.message })"
            if @options.verbose
              e.backtrace.each do | each |
                $stderr.puts each
                logger.debug each
              end
            end
          end
        end
      end


      ##########################################################################
      # First & Second Stage
      ##########################################################################


      def setup_first_stage
        Environment::FirstStage.new( debug_options, @messenger ).start( Nodes.load_all, @installer )
      end


      def setup_second_stage_for node
        Environment::SecondStage.new( debug_options, @messenger ).start( node )
      end


      def run_first_stage node, logger
        reboot_to_start_first_stage node, logger
        start_installer_for node, logger
      end


      def run_second_stage node, logger
        setup_second_stage_for node
        reboot_to_start_second_stage node, logger
        start_ldb node, logger
        @html_logger.update node, "ok"
        info "Node '#{ node.name }' installed."
      end


      def start_installer_for node, logger
        @installer.start node, @node_options[ node.name ].linux_image || @options.linux_image, @node_options[ node.name ].storage_conf, @ldb.local_clone_directory( @options.ldb_repository ), logger, @html_logger, debug_options, @messenger
      end


      ##########################################################################
      # Super Reboot
      ##########################################################################


      def start_super_reboot
        @super_reboot = SuperReboot.new( @html_logger, debug_options, @messenger )
      end


      def reboot_to_start_first_stage node, logger
        File.open( "/var/log/syslog", "r" ) do | syslog |
          @super_reboot.start_first_stage node, syslog, logger, @node_options[ node.name ].reboot_script
        end
        @html_logger.next_step node
      end


      def reboot_to_start_second_stage node, logger
        File.open( "/var/log/syslog", "r" ) do | syslog |
          @super_reboot.start_second_stage node, syslog, logger
        end
        @html_logger.next_step node
      end


      ##########################################################################
      # LDB
      ##########################################################################


      def setup_ldb
        @ldb = LDB.new( debug_options, @messenger )
        @ldb.clone @options.ldb_repository, lucie_server_ip, Lucie::Log
      end


      def start_ldb node, logger
        @html_logger.update node, "Starting LDB ..."
        @ldb.update node, @options.ldb_repository, logger
        @ldb.start node, @options.ldb_repository, logger
        @html_logger.next_step node
      end


      def lucie_server_ip
        subnet, netmask = Nodes.load_all.first.net_info
        NetworkInterfaces.select do | each |
          each.subnet == subnet and each.netmask == netmask
        end.first.ip_address
      end


      ##########################################################################
      # Logging
      ##########################################################################


      def start_main_logger
        Lucie::Log.path = File.join( Configuration.log_directory, "node-install-multi.log" )
        Lucie::Log.verbose = @verbose
        Lucie::Log.info "Lucie installer started."
      end


      def start_html_logger
        @html_logger = Lucie::Logger::HTML.new( { :dry_run => @dry_run }, @messenger )
        install_options = { :suite => @installer.suite, :ldb_repository => @options.ldb_repository,
          :package_repository => @installer.package_repository, :netmask => @options.netmask, :http_proxy => @installer.http_proxy }
        @html_logger.start install_options
        Nodes.load_all.each do | each |
          @html_logger.update each, "started"
        end
      end


      ##########################################################################
      # Nodes
      ##########################################################################


      def create_nodes
        @node_options.keys.each do | each |
          node = Node.new( each, node_options( each ) )
          Nodes.add node, debug_options, @messenger
        end
      end


      def node_options name
        {
          :ip_address => @node_options[ name ].address,
          :netmask_address => @options.netmask,
          :mac_address => @node_options[ name ].mac,
          :eth1 => @node_options[ name ].eth1,
          :eth2 => @node_options[ name ].eth2,
          :eth3 => @node_options[ name ].eth3,
          :eth4 => @node_options[ name ].eth4
        }
      end


      ##########################################################################
      # Misc.
      ##########################################################################


      def update_sudo_timestamp
        run %{sudo -v}, debug_options, @messenger
      end


      def setup_ssh
        run %{sudo ruby -pi -e "gsub( /.*ForwardAgent.*/, '    ForwardAgent yes' )" /etc/ssh/ssh_config}, debug_options, @messenger
      end


      def check_prerequisites
        Service.check_prerequisites debug_options, @messenger
      end


      def parse node_argv
        @node_options = {}
        node_argv.each do | name, argv |
          @node_options[ name ] = Command::NodeInstall::Options.new.parse( argv )
          @node_options[ name ].storage_conf ||= @options.storage_conf
          @node_options[ name ].check_mandatory_options
        end
      end


      def create_installer
        @installer = Installer.new
        @installer.http_proxy = @options.http_proxy if @options.http_proxy
        @installer.package_repository = @options.package_repository if @options.package_repository
        @installer.suite = @options.suite if @options.suite
        @installer.installer_linux_image = @options.installer_linux_image if @options.installer_linux_image 
        Installers.add @installer, debug_options, @messenger
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
