class SSH
  class CopyCommand
    def initialize from, to, command, logger, debug_options
      @from = from
      @to = to
      @command = command
      @logger = logger
      @debug_options = debug_options
    end


    def run
      SubProcess::Shell.open( @debug_options ) do | shell |
        set_stdout_handler_for shell
        set_stderr_handler_for shell
        spawn_subprocess shell, @command.command( @from, @to )
      end
    end


    ############################################################################
    private
    ############################################################################


    def set_stdout_handler_for shell
      shell.on_stdout { | line | @logger.debug line }
    end


    def set_stderr_handler_for shell
      shell.on_stdout { | line | @logger.debug line }
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
