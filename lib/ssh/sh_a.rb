require "ssh/shell-command"


class SSH
  class Sh_A
    include ShellCommand


    def run shell, logger
      begin
        agent_pid = run_with_ssh_agent( shell, logger )
      ensure
        kill_ssh_agent agent_pid, shell
      end
    end


    ############################################################################
    private
    ############################################################################


    def run_with_ssh_agent shell, logger
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


    def kill_ssh_agent agent_pid, shell
      shell.on_stdout {}
      shell.on_stderr {}
      shell.on_failure {}
      shell.exec "ssh-agent -k", { "SSH_AGENT_PID" => agent_pid }
    end


    def real_command
      %{eval `ssh-agent`; ssh-add #{ private_key_path }; ssh -A -i #{ private_key_path } #{ SSH::OPTIONS } root@#{ @ip } "#{ @command }"}
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
