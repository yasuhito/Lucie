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


  def enable_node node_name, installer_name
    Nodes.find( node_name ).enable! installer_name
  end


  def enable_nodes nodes, installer_name
    nodes.each do | each |
      enable_node( each, installer_name )
    end
  end


  def setup_tftp nodes, installer_name
    Tftp.setup nodes, installer_name
  end


  def remove_tftp node_name
    Tftp.remove! node_name
  end


  def setup_nfs
    Nfs.setup
  end


  def setup_dhcp
    Dhcp.setup
  end


  def setup_puppet installer_name
    PuppetController.setup Installers.find( installer_name ).local_checkout
  end


  def wol node_name
    node = Nodes.find( node_name )
    WakeOnLan.wake node.mac_address
  end


  def disable_node nodes
    nodes.each do | each |
      node = Nodes.find( each )
      if node
        node.disable!
        Tftp.disable each
      else
        raise "Node #{ each } not found!"
      end
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
