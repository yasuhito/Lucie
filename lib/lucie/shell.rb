require "lucie/debug"
require "lucie/log"
require "sub-process"


class Lucie::Shell
  include Lucie::Debug


  def initialize debug_options = {}
    @logger = Lucie::Log
    @debug_options = debug_options
  end


  def run command
    SubProcess.create( @debug_options ) do | shell |
      shell.on_stdout do | line |
        info line
      end
      shell.on_stderr do | line |
        error line
      end
      shell.on_failure do
        raise "'#{ command }' failed."
      end
      shell.exec command
    end
  end
end


def sh_exec command
  Lucie::Shell.new.run command
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
