require 'drb/drb'
require 'popen3/shell'
require 'rake'


module Daemon
  WorkingDirectory = File.expand_path( RAILS_ROOT )


  module Controller
    def self.start daemon
      fork do
        begin
          Process.setsid
          exit if fork
          LuciedBlocker.block
          LuciedBlocker::PidFile.store Process.pid
          Lucie::Log.debug "pwd = #{ WorkingDirectory }"
          Dir.chdir WorkingDirectory
          File.umask 0000

          Lucie::Log.verbose = true
          Lucie::Log.info 'Lucie daemon started.'

          STDIN.reopen '/dev/null'
          STDOUT.reopen '/dev/null', 'a'
          STDERR.reopen STDOUT
          trap( 'TERM' ) do
            daemon.stop
            exit
          end
          daemon.start
        rescue => e
          Lucie::Log.error e.message
          exit 1
        end
      end
    end


    def self.stop
      unless File.file?( LuciedBlocker::PidFile.file_name )
        Lucie::Log.error 'Pid file not found. Is the daemon started?'
        exit
      end
      pid = LuciedBlocker::PidFile.recall
      LuciedBlocker.release
      pid && Process.kill( 'TERM', pid )
    end
  end
end


class LucieDaemon
  PORT = 58243


  ################################################################################
  # Daemon management
  ################################################################################


  def self.server
    DRbObject.new_with_uri( uri )
  end


  def self.daemonize
    Daemon::Controller.start self
  end


  def self.kill
    Daemon::Controller.stop
  end


  ################################################################################
  # Helpers
  ################################################################################


  # [XXX] We should make sure that only the lucie server can call sudo
  def sudo command, log_fn = nil
    log = log_fn ? File.open( log_fn, 'w' ) : STDOUT
    log.sync = true

    Lucie::Log.event command
    log.puts command

    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        Lucie::Log.info line
        log.puts line
      end
      shell.on_stderr do | line |
        Lucie::Log.info line
        log.puts line
      end

      shell.on_failure do
        raise "#{ command } failed."
      end

      shell.exec( command, { :env => { 'LC_ALL' => 'C' } } )

      log.close if log_fn

      shell
    end
  end


  def enable_node node_name, installer_name, wol
    load "#{ RAILS_ROOT }/lib/tasks/enable_node.rake"

    ENV[ 'NODE_NAME' ] = node_name
    ENV[ 'INSTALLER_NAME' ] = installer_name
    ENV[ 'WOL' ] = wol ? '1' : nil

    Rake::Task[ 'lucie:enable_node' ].execute
  end


  def disable_node node_name
    node = Nodes.find( node_name )
    if node
      node.disable!
      Tftp.disable node_name
    else
      raise "Node #{ node_name } not found!"
    end
  end


  def restart_puppet
    PuppetController.restart
  end


  ################################################################################
  # Misc (used internally)
  ################################################################################


  def self.uri
    "druby://127.0.0.1:#{ PORT }"
  end


  def self.start
    DRb.start_service uri, self.new
    DRb.thread.join
  end


  def self.stop
    DRb.stop_service
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
