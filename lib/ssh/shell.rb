class SSH
  module Shell
    def initialize logger
      @logger = logger
      @output = ""
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
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
