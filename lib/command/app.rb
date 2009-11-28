require "configuration"
require "configurator"
require "environment"
require "installer"
require "installers"
require "lucie/debug"
require "lucie/io"
require "lucie/logger/html"
require "lucie/server"
require "lucie/utils"
require "ssh"
require "stop-watch"
require "super-reboot"
require "thread_pool"


module Command
  class App
    include Lucie::Debug
    include Lucie::IO
    include Lucie::Utils


    def initialize argv, debug_options
      @argv = argv
      @global_options = parse_argv
      @debug_options = { :verbose => @global_options.verbose, :dry_run => @global_options.dry_run }.merge( debug_options )
      @tp = ThreadPool.new
      usage_and_exit if @global_options.help
      @global_options.check_mandatory_options
    end


    def usage_and_exit
      print @global_options.usage
      exit 0
    end


    ############################################################################
    private
    ############################################################################


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


    # First and Second Stage ###################################################


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


    # Configurator #############################################################


    def start_ldb node, logger
      @html_logger.proceed_to_next_step node, "Starting LDB ..."
      logger.info "Starting LDB ..."
      if @global_options.ldb_repository
        @configurator.clone_to_client @global_options.ldb_repository, node, lucie_server_ip_address, logger
        @configurator.start node, logger
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


    # Misc. ####################################################################


    def lucie_server_ip_address
      if dry_run and @debug_options[ :nic ]
        @debug_options[ :nic ].first.ip_address
      else
        Lucie::Server.ip_address_for Nodes.load_all
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
