require "configuration"
require "configurator"
require "environment"
require "highline"
require "installer"
require "installers"
require "lucie/log"
require "lucie/logger/html"
require "lucie/utils"
require "nodes"
require "service"
require "ssh"
require "super-reboot"


module Command
  module Installer
    include Lucie::Utils
    include Lucie::Debug


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
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
