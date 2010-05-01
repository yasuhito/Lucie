require "ssh/path"


class SSH
  #
  # scp with logging.
  #
  class ScprProcess
    include Path


    def initialize from, to, logger, debug_options
      @from = from
      @to = to
      @logger = logger
      @debug_options = debug_options
    end


    def run
      SubProcess::Shell.open( @debug_options ) do | shell |
        set_handlers_for shell
        spawn_subprocess shell, "scp -i #{ private_key } #{ SSH::OPTIONS } -r #{ @from } #{ @to }"
      end
    end


    ############################################################################
    private
    ############################################################################


    def set_handlers_for shell
      default_handler = lambda { | line | @logger.debug line }
      [ :on_stdout, :on_stderr ].each do | each |
        shell.__send__ each, &default_handler
      end
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
