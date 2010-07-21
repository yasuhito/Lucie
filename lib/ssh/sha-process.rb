require "ssh/shell-process"


#
# Run a command via SSH with agent forwarding enabled. The following
# options are available:
#
# <tt>:logger</tt>:: Save logs with the specified logger [nil]
# <tt>:verbose</tt>:: Be verbose [nil] 
# <tt>:dry_run</tt>:: Print the commands that would be executed, but do not execute them. [nil]
#
# Usage:
#
#   # run `ls /home' on yasuhito_desktop
#   SSH::ShaProcess.new( "yasuhito_desktop", "ls /home" ).run
#
#   # run `ls /home' on yasuhito_desktop, with logging
#   SSH::ShaProcess.new( "yasuhito_desktop", "ls /home", :logger => logger ).run
#
#   # run `ls /home' on yasuhito_desktop, verbose mode
#   SSH::ShaProcess.new( "yasuhito_desktop", "ls /home", :verbose => true ).run
#
#   # run `ls /home' on yasuhito_desktop, dry-run mode
#   SSH::ShaProcess.new( "yasuhito_desktop", "ls /home", :dry_run => true ).run
#   
class SSH::ShaProcess < SSH::ShellProcess
  #
  # Run a command via SSH with agent forwarding enabled.
  #
  # Usage:
  #
  #   SSH::ShaProcess.new( "yasuhito_desktop", "ls /home" ).run
  #
  def run
    SubProcess.create( @debug_options ) do | shell |
      begin
        set_default_handlers_for shell
        spawn_subprocess shell, real_command
      ensure
        kill_ssh_agent shell
      end
    end
    self
  end


  ##############################################################################
  private
  ##############################################################################


  def kill_ssh_agent shell
    shell.exec "ssh-agent -k", { "SSH_AGENT_PID" => $1 } if /^Agent pid (\d+)/=~ @output
  end


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
