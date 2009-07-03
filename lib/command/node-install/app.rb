require "command/app"
require "configuration"
require "environment"
require "installer"
require "installers"
require "ldb"
require "lucie/utils"
require "mandatory_option_error"
require "node"
require "nodes"
require "ssh"
require "super-reboot"


module Command
  module NodeInstall
    class App < Command::App
      include Lucie::Utils


      def initialize argv = ARGV, messenger = nil
        super argv, messenger
      end


      def main node_name
        update_sudo_timestamp
        start_main_logger
        check_prerequisites
        create_node node_name
        setup_ldb
        create_installer
        start_html_logger

        start_lucie_logger
        setup_first_stage
        install_parallel node
      end


      ##########################################################################
      private
      ##########################################################################


      def start_html_logger
        @html_logger = Lucie::Logger::HTML.new( { :dry_run => @dry_run }, @messenger )
        install_options = { :suite => @installer.suite, :ldb_repository => @options.ldb_repository,
          :package_repository => @installer.package_repository, :netmask => @options.netmask, :http_proxy => @installer.http_proxy }
        @html_logger.start install_options
        Nodes.load_all.each do | each |
          @html_logger.update each, "started"
        end
      end


      def lucie_server_ip
        subnet, netmask = Nodes.load_all.first.net_info
        NetworkInterfaces.select do | each |
          each.subnet == subnet and each.netmask == netmask
        end.first.ip_address
      end


      def setup_ldb
        return unless @options.ldb_repository
        @ldb = LDB.new( debug_options, @messenger )
        @ldb.clone @options.ldb_repository, lucie_server_ip, Lucie::Log
      end


      def check_prerequisites
        Service.check_prerequisites debug_options, @messenger
      end


      def start_main_logger
        Lucie::Log.path = File.join( Configuration.log_directory, "node-install-multi.log" )
        Lucie::Log.verbose = @verbose
        Lucie::Log.info "Lucie installer started."
      end


      def update_sudo_timestamp
        run %{sudo -v}, debug_options, @messenger
      end


      def setup_first_stage
        Environment::FirstStage.new( debug_options, @messenger ).start( Nodes.load_all, @installer )
      end


      def start_lucie_logger
        Lucie::Log.path = File.join( Configuration.log_directory, "node-install.log" )
        Lucie::Log.verbose = @verbose
        Lucie::Log.info "Lucie installer started."
      end


      def create_installer
        @installer = Installer.new
        @installer.http_proxy = @options.http_proxy if @options.http_proxy
        @installer.package_repository = @options.package_repository if @options.package_repository
        @installer.suite = @options.suite if @options.suite
        Installers.add @installer, debug_options, @messenger
      end


      def install_parallel node
        log_directory = Lucie::Logger::Installer.new_log_directory( node, debug_options, @messenger )
        logger = Lucie::Logger::Installer.new( log_directory, @dry_run )
        install node, logger
        log_installation_success node
      end


      def install node, logger
        reboot node
        start_installer_for node, logger
      end


      def reboot node
        reboot_options = { :script => @options.reboot_script, :ssh => true, :manual => true }
        SuperReboot.new( @html_logger, { :verbose => @options.verbose, :dry_run => @options.dry_run }, @messenger ).start_first_stage node, reboot_options
      end


      def start_installer_for node, logger
        @installer.start node, @options.linux_image, @options.storage_conf, logger, @html_logger, debug_options, @messenger
      end


      def create_node node_name
        node = Node.new( node_name, node_options )
        Nodes.add node, debug_options, @messenger
      end


      def node_options
        { :netmask_address => @options.netmask, :mac_address => @options.mac,
          :eth1 => @options.eth1, :eth2 => @options.eth2, :eth3 => @options.eth3, :eth4 => @options.eth4 }
      end


      ##########################################################################
      # Logging
      ##########################################################################


      def log_installation_success node
        info "Node '#{ node.name }' installed."
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
