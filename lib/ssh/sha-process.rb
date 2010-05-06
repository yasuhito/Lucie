require "ssh/shell-process"


#
# ssh -a with logging
#
class SSH::ShaProcess < SSH::ShellProcess # :nodoc:
  ##############################################################################
  private
  ##############################################################################


  def kill_ssh_agent shell
    shell.exec "ssh-agent -k", { "SSH_AGENT_PID" => $1 } if /^Agent pid (\d+)/=~ @output
  end
  alias post_command_hook kill_ssh_agent


  def real_command
    %{#{ start_ssh_agent }; ssh -A -i #{ private_key } #{ SSH::OPTIONS } root@#{ @host_name } "#{ @command_line }"}
  end


  def start_ssh_agent
    "eval `ssh-agent`; ssh-add #{ private_key }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
