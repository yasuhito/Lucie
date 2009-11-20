require "lucie/debug"


class SSH
  class CopyCommand
    include Lucie::Debug


    def initialize from, to, command, debug_options
      @from = from
      @to = to
      @command = command
      @debug_options = debug_options
    end


    def run logger
      SubProcess::Shell.open( @debug_options ) do | shell |
        shell.on_stdout do | line |
          stdout.puts line
          logger.debug line
        end
        shell.on_stderr do | line |
          stderr.puts line
          logger.debug line
        end
        logger.debug real_command
        shell.exec real_command
      end
    end


    ############################################################################w
    private
    ############################################################################w


    def real_command
      @command.command @from, @to
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
