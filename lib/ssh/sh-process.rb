require "ssh/path"
require "ssh/shell"


class SSH
  #
  # ssh with logging
  #
  class ShProcess
    include Path
    include Shell


    attr_reader :output


    def initialize host_name, command_line, logger, debug_options
      @host_name = host_name
      @command_line = command_line
      @output = ""
      @logger = logger
      @debug_options = debug_options
    end


    def run
      SubProcess::Shell.open( @debug_options ) do | shell |
        set_handlers_for shell
        spawn_subprocess shell, real_command( @host_name, @command_line )
      end
      self
    end


    ############################################################################
    private
    ############################################################################


    def real_command host_name, command
      %{ssh -i #{ private_key } #{ SSH::OPTIONS } root@#{ host_name } "#{ command }"}
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
