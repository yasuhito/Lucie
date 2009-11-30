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


    def maybe_generate_and_authorize_keypair
      SSH.new( @debug_options ).maybe_generate_and_authorize_keypair
    end


    def update_sudo_timestamp
      run %{sudo -v}, @debug_options
    end


    def start_main_logger
      Lucie::Log.path = File.join( Configuration.log_directory, "install.log" )
      Lucie::Log.verbose = verbose
      Lucie::Log.info "Lucie installer started."
    end


    def check_prerequisites
      Service.check_prerequisites @debug_options
    end


    def start_secret_server
      if @global_options.secret
        unless ENV[ "LUCIE_PASSWORD" ]
          IO.read @global_options.secret
          ENV[ "LUCIE_PASSWORD" ] = HighLine.new.ask( "Please enter password to decrypt #{ @global_options.secret }:" ) do | q |
            q.echo = "*"
          end
        end

        @sspid = fork do
          cmd = "#{ File.expand_path( File.dirname( __FILE__ ) + '/../../script/confidential-data-server' ) } --encrypted-file #{ @global_options.secret } #{ verbose ? '--verbose' : '' }"
          exec cmd
        end

        t = Thread.new( @sspid ) do | pid |
          Process.waitpid pid
          Thread.main.raise "Secret server exitted abnormally"
        end
        t.priority = -10
      end
    end


    def setup_ldb
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


    def start_super_reboot
      @super_reboot = SuperReboot.new( @debug_options )
    end


    def setup_ssh
      run %{sudo ruby -pi -e "gsub( /.*ForwardAgent.*/, '    ForwardAgent yes' )" /etc/ssh/ssh_config}, @debug_options
    end


    def setup_first_stage
      if dry_run and @debug_options[ :nic ]
        Environment::FirstStage.new( @debug_options ).start( Nodes.load_all, @installer, "/etc/inetd.conf", @debug_options[ :nic ] )
      else
        Environment::FirstStage.new( @debug_options ).start( Nodes.load_all, @installer, "/etc/inetd.conf" )
      end
    end


    def install_parallel
      begin
        Nodes.load_all.collect do | each |
          @tp.dispatch( each ) do | each |
            sleep 1
            log_directory = Lucie::Logger::Installer.new_log_directory( each, @debug_options, @debug_options[ :messenger ] )
            logger = Lucie::Logger::Installer.new( log_directory, @debug_options )
            each.status = Status::Installer.new( log_directory, @debug_options, @debug_options[ :messenger ] )
            start_installer each, logger
          end
        end
        @tp.shutdown
      rescue Exception => e
        @tp.killall
        Nodes.load_all.each do | each |
          if each.status.incomplete?
            each.status.fail!
            emsg= e.message.empty? ? e.inspect : e.message
            @html_logger.update_status each, "failed (#{ emsg })"
          end
        end
      ensure
        Process.kill( "TERM", @sspid ) if @sspid
      end
    end


    def start_installer node, logger
      begin
        node.status.start!
        run_first_reboot node, logger
        run_first_stage node, logger
        run_second_reboot node, logger
        run_second_stage node, logger
        node.status.succeed!
        @html_logger.proceed_to_next_step node, "ok"
      rescue Exception => e
        node.status.fail!
        $stderr.puts e.message
        logger.error e.message
        @html_logger.update_status node, "failed (#{ e.message })"
        if @global_options.verbose
          e.backtrace.each do | each |
            $stderr.puts each
            logger.debug each
          end
        end
      end
    end


    def run_first_reboot node, logger
      time = StopWatch.time_to_run do
        unless dry_run
          File.open( "/var/log/syslog", "r" ) do | syslog |
            begin
              @html_logger.proceed_to_next_step node, "Rebooting"
              logger.info "Rebooting"
              @super_reboot.start_first_stage node, syslog, logger
            rescue
              @html_logger.proceed_to_next_step node, "Requesting manual reboot"
              logger.info "Requesting manual reboot"
              @super_reboot.wait_manual_reboot node, syslog, logger
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
            @super_reboot.start_second_stage node, syslog, logger
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
      logger.info "Node '#{ node.name }' installed."
      info "Node '#{ node.name }' installed."
    end


    def start_ldb node, logger
      @html_logger.proceed_to_next_step node, "Starting LDB ..."
      logger.info "Starting LDB ..."
      if @global_options.ldb_repository
        @configurator.clone_to_client @global_options.ldb_repository, node, lucie_server_ip_address, logger
        @configurator.start node, logger
      end
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
