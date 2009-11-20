class SSH
  class CopyCommand
    def initialize command_type, debug_options
      @command_type = command_type
      @debug_options = debug_options
    end


    def run from, to, logger
      SubProcess::Shell.open( @debug_options ) do | shell |
        @command_type.run from, to, shell, logger
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
