require "lucie/debug"


class SSH
  class Sh_A
    include Lucie::Debug


    attr_reader :agent_pid


    def initialize ip, command, priv_key
      @ip = ip
      @command = command
      @priv_key = priv_key
      @agent_pid = nil
    end


    def run shell, logger
      shell.on_stdout do | line |
        @agent_pid = $1 if /^Agent pid (\d+)/=~ line
        stdout.puts line
        logger.debug line
      end
      shell.on_stderr do | line |
        stderr.puts line
        logger.debug line
      end
      shell.on_failure do
        raise "command #{ @command } failed on #{ @ip }"
      end
      logger.debug real_command
      shell.exec real_command
      @agent_pid
    end


    ############################################################################
    private
    ############################################################################


    def real_command
      %{eval `ssh-agent`; ssh-add #{ @priv_key }; ssh -A -i #{ @priv_key } #{ SSH::OPTIONS } root@#{ @ip } "#{ @command }"}
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
