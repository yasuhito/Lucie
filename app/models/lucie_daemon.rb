require 'command_line'
require 'drb/drb'


class LucieDaemon
  include CommandLine


  PORT = 58243


  def self.start
    DRb.start_service( uri, self.new )
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
