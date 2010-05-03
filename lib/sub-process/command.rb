#
# Starts a command with specified environment variables.
#
class SubProcess::Command # :nodoc:
  attr_reader :command
  attr_reader :env


  def initialize command, env = {}
    @command = command
    @env = env
  end


  def start
    @env.each_pair do | key, value |
      ENV[ key ]= value
    end
    Kernel.exec @command
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
