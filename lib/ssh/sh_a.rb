require "ssh/shell-command"


class SSH
  class Sh_A
    include ShellCommand


    def run shell, logger
      agent_pid = nil
      shell.on_stdout do | line |
        agent_pid = $1 if /^Agent pid (\d+)/=~ line
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
      agent_pid
    end


    ############################################################################
    private
    ############################################################################


    def real_command
      %{eval `ssh-agent`; ssh-add #{ private_key_path }; ssh -A -i #{ @priv_key } #{ SSH::OPTIONS } root@#{ @ip } "#{ @command }"}
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
