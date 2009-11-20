class SSH
  class ShellCommand
    def initialize ip, command_line, command, debug_options
      @ip = ip
      @command_line = command_line
      @command = command
      @debug_options = debug_options
    end


    def run logger
      SubProcess::Shell.open( @debug_options ) do | shell |
        @command.run @ip, @command_line, shell, logger
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
