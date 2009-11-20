class SSH
  class ShellCommand
    def initialize host_name, command_line, command, debug_options
      @host_name = host_name
      @command_line = command_line
      @command = command
      @debug_options = debug_options
    end


    def run
      SubProcess::Shell.open( @debug_options ) do | shell |
        @command.run @host_name, @command_line, shell
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
