require "ssh/home"


class SSH
  module CopyCommand
    include Home


    def initialize from, to, debug_options
      @from = from
      @to = to
      @debug_options = debug_options
    end


    def run shell, logger
      shell.on_stdout do | line |
        stdout.puts line
        logger.debug line
      end
      shell.on_stderr do | line |
        stderr.puts line
        logger.debug line
      end
      logger.debug command
      shell.exec command
    end


    ############################################################################
    private
    ############################################################################


    def command
      raise NotImplementedError
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
