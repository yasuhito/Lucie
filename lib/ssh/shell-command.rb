class SSH
  class ShellCommand
    def initialize command_type, debug_options
      @command_type = command_type
      @debug_options = debug_options
    end


    def run ip, command, logger
      SubProcess::Shell.open( @debug_options ) do | shell |
        @command_type.run ip, command, shell, logger
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
