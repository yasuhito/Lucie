require "lucie/debug"


class SSH
  class CopyCommand
    include Lucie::Debug


    def initialize command, debug_options
      @command = command
      @debug_options = debug_options
    end


    def run from, to, logger
      SubProcess::Shell.open( @debug_options ) do | shell |
        shell.on_stdout do | line |
          stdout.puts line
          logger.debug line
        end
        shell.on_stderr do | line |
          stderr.puts line
          logger.debug line
        end
        logger.debug @command.command( from, to )
        shell.exec @command.command( from, to )
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
