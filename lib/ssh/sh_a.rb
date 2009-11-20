require "ssh/home"


class SSH
  class Sh_A
    include Home


    def initialize logger
      @logger = logger
      @output = []
    end


    def run ip, command, shell
      begin
        run_with_ssh_agent ip, command, shell
      ensure
        kill_ssh_agent shell
      end
    end


    ############################################################################
    private
    ############################################################################


    def run_with_ssh_agent ip, command, shell
      set_stdout_handler_for shell
      set_stderr_handler_for shell
      spawn_subprocess shell, real_command( ip, command )
    end


    def set_stdout_handler_for shell
      shell.on_stdout { | line | @output << line; @logger.debug( line ) }
    end


    def set_stderr_handler_for shell
      shell.on_stderr { | line | @output << line; @logger.debug( line ) }
    end


    def spawn_subprocess shell, command
      @logger.debug command
      shell.exec command
    end


    def kill_ssh_agent shell
      shell.exec "ssh-agent -k", { "SSH_AGENT_PID" => $1 } if /^Agent pid (\d+)/=~ @output.join( "\n" )
    end


    def real_command ip, command
      %{eval `ssh-agent`; ssh-add #{ private_key_path }; ssh -A -i #{ private_key_path } #{ SSH::OPTIONS } root@#{ ip } "#{ command }"}
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
