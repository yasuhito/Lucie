require 'command_line'
require 'drb/drb'


class LucieDaemon
  include CommandLine


  PORT = 58243


  def self.start_service
    DRb.start_service( uri, self.new )
  end


  def self.pid_file_name
    "#{ RAILS_ROOT }/tmp/pids/lucied.pid"
  end


  # [TODO] lucied must be exclusive (LuciedBlocker class ?)
  def self.start
    pid = fork || exec( "#{ RAILS_ROOT }/script/lucied" )

    lucied_pid_location = "#{ RAILS_ROOT }/tmp/pids/"

    FileUtils.mkdir_p File.dirname( pid_file_name )
    File.open( pid_file_name, 'w' ) do | f |
      f.write pid
    end
  end


  def self.stop
    pid = nil
    File.open( pid_file_name, 'r' ) do | f |
      pid = f.read
    end
    system "kill #{ pid }"
    File.delete pid_file_name
  end


  def self.uri
    "druby://localhost:#{ PORT }"
  end


  def sudo command = nil
    if command
      execute command
    end
    if block_given?
      yield
    end
  end


  ##############################################################################
  # Helper methods
  ##############################################################################


  def restart_puppet
    Puppet.restart
  end
end
