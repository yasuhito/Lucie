require "ssh/path"
require "ssh/shell"


class SSH
  #
  # Executes a command with ssh-agent.
  #
  class ShAgent
    include Path
    include Shell


    def run host_name, command, shell
      begin
        set_handlers_for shell
        spawn_subprocess shell, real_command( host_name, command )
      ensure
        kill_ssh_agent shell
      end
    end


    ############################################################################
    private
    ############################################################################


    def kill_ssh_agent shell
      shell.exec "ssh-agent -k", { "SSH_AGENT_PID" => $1 } if /^Agent pid (\d+)/=~ @output
    end


    def real_command host_name, command
      %{#{ start_ssh_agent }; ssh -A -i #{ private_key } #{ SSH::OPTIONS } root@#{ host_name } "#{ command }"}
    end


    def start_ssh_agent
      "eval `ssh-agent`; ssh-add #{ private_key }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
