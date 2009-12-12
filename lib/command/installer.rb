require "configuration"
require "configurator"
require "environment"
require "highline"
require "installer"
require "installers"
require "lucie/io"
require "lucie/log"
require "lucie/logger/html"
require "lucie/utils"
require "nodes"
require "service"
require "ssh"
require "stop-watch"
require "super-reboot"


module Command
  module Installer
    include Lucie::Debug
    include Lucie::IO
    include Lucie::Utils


    def start_main_logger
      Lucie::Log.path = File.join( Configuration.log_directory, "install.log" )
      Lucie::Log.verbose = verbose
      Lucie::Log.info "Lucie installer started."
    end


    def check_prerequisites
      Service.check_prerequisites @debug_options
    end


    def maybe_generate_and_authorize_keypair
      SSH.new( @debug_options ).maybe_generate_and_authorize_keypair
    end


    def update_sudo_timestamp
      run %{sudo -v}, @debug_options
    end


    def maybe_start_confidential_data_server
      return unless @global_options.secret
      password = HighLine.new.ask( "Please enter password to decrypt #{ @global_options.secret }:" ) do | q |
        q.echo = "*"
      end
      Blocker.fork( "confidential-data-server" ) do
        ConfidentialDataServer.new( @global_options.secret, password, @debug_options ).start
      end
    end


    def maybe_setup_ldb
      return unless @global_options.ldb_repository
      @configurator = Configurator.new( @global_options.source_control || "Mercurial", @debug_options )
      if FileTest.directory?( Configurator::Server.clone_directory( @global_options.ldb_repository ) )
        @configurator.update_server @global_options.ldb_repository
      else
        @configurator.clone_to_server @global_options.ldb_repository, lucie_server_ip_address
      end
    end


    def create_installer
      @installer = ::Installer.new
      @installer.http_proxy = @global_options.http_proxy if @global_options.http_proxy
      @installer.package_repository = @global_options.package_repository if @global_options.package_repository
      @installer.suite = @global_options.suite if @global_options.suite
      @installer.installer_linux_image = @global_options.installer_linux_image if @global_options.installer_linux_image
      Installers.add @installer, @debug_options, @debug_options[ :messenger ]
    end


    def start_html_logger
      @html_logger = Lucie::Logger::HTML.new( :dry_run => dry_run, :messenger => messenger )
      install_options = { :suite => @installer.suite, :ldb_repository => @global_options.ldb_repository,
        :package_repository => @installer.package_repository, :http_proxy => @installer.http_proxy }
      @html_logger.start install_options
      Nodes.load_all.each do | each |
        @html_logger.update_status each, "started"
      end
    end


    def setup_ssh_forward_agent
      run %{sudo ruby -pi -e "gsub( /.*ForwardAgent.*/, '    ForwardAgent yes' )" /etc/ssh/ssh_config}, @debug_options
    end


    def setup_first_stage_environment
      if dry_run and @debug_options[ :nic ]
        Environment::FirstStage.new( @debug_options ).start( Nodes.load_all, @installer, "/etc/inetd.conf", @debug_options[ :nic ] )
      else
        Environment::FirstStage.new( @debug_options ).start( Nodes.load_all, @installer, "/etc/inetd.conf" )
      end
    end


    def disable_network_boot node
      Service::Tftp.new( @debug_options ).reset node
    end


    def run_first_reboot node, logger
      time = StopWatch.time_to_run do
        unless dry_run
          File.open( "/var/log/syslog", "r" ) do | syslog |
            begin
              @html_logger.proceed_to_next_step node, "Rebooting"
              logger.info "Rebooting"
              SuperReboot.new( node, syslog, logger, @debug_options ).start_first_stage
            rescue
              @html_logger.update_status node, "Requesting manual reboot"
              logger.info "Requesting manual reboot"
              SuperReboot.new( node, syslog, logger, @debug_options ).wait_manual_reboot
            end
          end
        end
      end
      logger.info "The first reboot finished in #{ time } seconds."
    end


    def run_first_stage node, logger
      time = StopWatch.time_to_run do
        start_installer_for node, logger
      end
      logger.info "The first stage finished in #{ time } seconds."
    end


    def run_second_reboot node, logger
      time = StopWatch.time_to_run do
        Environment::SecondStage.new( @debug_options ).start( node )
        unless dry_run
          File.open( "/var/log/syslog", "r" ) do | syslog |
            @html_logger.proceed_to_next_step node, "Rebooting"
            logger.info "Rebooting"
            SuperReboot.new( node, syslog, logger, @debug_options ).start_second_stage
          end
        end
      end
      logger.info "The second reboot finished in #{ time } seconds."
    end


    def run_second_stage node, logger
      time = StopWatch.time_to_run do
        start_ldb node, logger
      end
      logger.info "The second stage finished in #{ time } seconds."
    end


    def start_ldb node, logger
      @html_logger.proceed_to_next_step node, "Starting LDB ..."
      logger.info "Starting LDB ..."
      if @global_options.ldb_repository
        @configurator.clone_to_client @global_options.ldb_repository, node, lucie_server_ip_address, logger
        @configurator.start node, logger
      end
    end


    def run_third_reboot node, logger
      @html_logger.proceed_to_next_step node, "Rebooting"
      time = StopWatch.time_to_run do
        unless dry_run
          File.open( "/var/log/syslog", "r" ) do | syslog |
            logger.info "Rebooting"
            SuperReboot.new( node, syslog, logger, @debug_options ).reboot_to_finish_installation
          end
        end
      end
      logger.info "The third reboot finished in #{ time } seconds."
    end


    def lucie_server_ip_address
      Lucie::Server.ip_address_for Nodes.load_all, @debug_options
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
