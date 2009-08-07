require "configuration"
require "configurator"
require "environment"
require "highline"
require "installer"
require "installers"
require "ldb"
require "lucie/io"
require "lucie/logger/html"
require "lucie/server"
require "lucie/utils"
require "secret-server"
require "ssh"
require "super-reboot"


module Command
  class App
    include Lucie::IO
    include Lucie::Utils


    attr_reader :options


    def initialize argv, messenger
      @argv = argv
      @options = parse_argv
      @dry_run = @options.dry_run
      @verbose = @options.verbose
      @messenger = messenger
      usage_and_exit if @options.help
      @options.check_mandatory_options
    end


    def usage_and_exit
      print @options.usage
      exit 0
    end


    ############################################################################
    private
    ############################################################################


    def generate_ssh_keypair
      SSH.new( debug_options, @messenger ).generate_keypair
    end


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


    # First Stage ##############################################################


    def setup_first_stage
      Environment::FirstStage.new( debug_options, @messenger ).start( Nodes.load_all, @installer )
    end


    def reboot_to_start_first_stage node, logger
      File.open( "/var/log/syslog", "r" ) do | syslog |
        @super_reboot.start_first_stage node, syslog, logger
      end
      @html_logger.next_step node
    end


    def run_first_stage node, logger
      reboot_to_start_first_stage node, logger
      start_installer_for node, logger
    end


    # Second Stage #############################################################


    def setup_second_stage_for node
      Environment::SecondStage.new( debug_options, @messenger ).start( node )
    end


    def reboot_to_start_second_stage node, logger
      File.open( "/var/log/syslog", "r" ) do | syslog |
        @super_reboot.start_second_stage node, syslog, logger
      end
      @html_logger.next_step node
    end


    def run_second_stage node, logger
      setup_second_stage_for node
      reboot_to_start_second_stage node, logger
      start_ldb node, logger
      @html_logger.update node, "ok"
      logger.info "Node '#{ node.name }' installed."
      info "Node '#{ node.name }' installed."
    end


    # Configurator #############################################################


    def setup_ldb
      return unless @options.ldb_repository
      @configurator = Configurator.new( debug_options.merge( :messenger => @messenger ) )
      if FileTest.directory?( Configurator::Server.clone_directory( @options.ldb_repository ) )
        @configurator.update_server Nodes.load_all
      else
        @configurator.clone_to_server @options.ldb_repository, Lucie::Server.ip_address_for( Nodes.load_all )
      end
    end


    def start_ldb node, logger
      if @options.ldb_repository
        @html_logger.update node, "Starting LDB ..."
        logger.info "Starting LDB ..."
        @configurator.clone_to_client @options.ldb_repository, node, Lucie::Server.ip_address_for( Nodes.load_all )
        @configurator.start node, logger
      end
      @html_logger.next_step node
    end


    # Logging ##################################################################


    def start_main_logger
      Lucie::Log.path = File.join( Configuration.log_directory, "install.log" )
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


    # Options ##################################################################


    def parse_argv
      options_class.new.parse @argv
    end


    def options_class
      instance_eval do | obj |
        eval ( obj.class.to_s.split( "::" )[ 0..-2 ] + [ "Options" ] ).join( "::" )
      end
    end


    def debug_options
      { :verbose => @verbose, :dry_run => @dry_run }
    end


    # Misc. ####################################################################


    def start_secret_server
      if @options.secret
        IO.read @options.secret
        password = HighLine.new.ask( "Please enter password to decrypt #{ @options.secret }:" ) do | q |
          q.echo = "*"
        end
        secret_server = SecretServer.new( @options.secret, password, debug_options )
        @secret_server = Thread.start do
          secret_server.start
        end
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


    def start_super_reboot
      @super_reboot = SuperReboot.new( @html_logger, debug_options, @messenger )
    end


    def check_prerequisites
      Service.check_prerequisites debug_options, @messenger
    end


    def update_sudo_timestamp
      run %{sudo -v}, debug_options, @messenger
    end


    def setup_ssh
      run %{sudo ruby -pi -e "gsub( /.*ForwardAgent.*/, '    ForwardAgent yes' )" /etc/ssh/ssh_config}, debug_options, @messenger
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
