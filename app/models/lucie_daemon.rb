require RAILS_ROOT + '/config/environment'

require 'debootstrap'
require 'drb/drb'
require 'fileutils'
require 'node'
require 'nodes'
require 'popen3/shell'
require 'puppet'
require 'tftp'


module Daemon
  WorkingDirectory = File.expand_path(File.dirname(__FILE__))


  class Base
    def self.pid_fn
      File.join(WorkingDirectory, "#{name}.pid")
    end

    def self.daemonize
      Controller.daemonize(self)
    end
  end


  module PidFile
    def self.store(daemon, pid)
      File.open(daemon.pid_fn, 'w') {|f| f << pid}
    end

    def self.recall(daemon)
      IO.read(daemon.pid_fn).to_i rescue nil
    end
  end


  module Controller
    def self.daemonize(daemon)
      case !ARGV.empty? && ARGV[0]
      when 'start'
        start(daemon)
      when 'stop'
        stop(daemon)
      when 'restart'
        stop(daemon)
        start(daemon)
      else
        puts "Invalid command. Please specify start, stop or restart."
        exit
      end
    end


    def self.start(daemon)
      fork do
        Process.setsid
        exit if fork
        PidFile.store(daemon, Process.pid)
        Dir.chdir WorkingDirectory
        File.umask 0000
        STDIN.reopen "/dev/null"
        STDOUT.reopen "/dev/null", "a"
        STDERR.reopen STDOUT
        trap("TERM") { daemon.stop; exit }
        daemon.start
      end
    end


    def self.stop(daemon)
      if !File.file?(daemon.pid_fn)
        puts "Pid file not found. Is the daemon started?"
        exit
      end
      pid = PidFile.recall(daemon)
      FileUtils.rm(daemon.pid_fn)
      pid && Process.kill("TERM", pid)
    end
  end
end


class LucieDaemon < Daemon::Base
  PORT = 58243


  def self.daemonize
    Daemon::Controller.start( self )
  end


  def self.pid_fn
    LuciedBlocker.pid_file
  end


  def self.start
    DRb.start_service( uri, self.new )
    DRb.thread.join
  end


  def self.stop
    DRb.stop_service
  end


  def self.uri
    "druby://localhost:#{ PORT }"
  end


  def sudo command
    Lucie::Log.info '[lucied] ' + command
    return sh_exec( command )
  end


  ##############################################################################
  # Helper methods
  ##############################################################################


  def disable_node node_name
    node = Nodes.find( node_name )
    if node
      node.disable!
      Tftp.disable node
    else
      raise "Node #{ node_name } not found!"
    end
  end


  def debootstrap options
    Debootstrap.start options
  end


  def restart_puppet
    Puppet.restart
  end
end
