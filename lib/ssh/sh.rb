require "ssh/home"


class SSH
  class Sh
    include Home


    attr_reader :output


    def initialize logger
      @logger = logger
      @output = ""
    end


    def run ip, command, shell
      set_stdout_handler_for shell
      set_stderr_handler_for shell
      spawn_subprocess shell, real_command( ip, command )
      self
    end


    ############################################################################
    private
    ############################################################################


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


    def real_command ip, command
      %{ssh -i #{ private_key_path } #{ SSH::OPTIONS } root@#{ ip } "#{ command }"}
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
