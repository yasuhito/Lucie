require "lucie/log"
require "sub-process"


module Lucie
  class Shell
    def initialize options = {}, messenger = nil
      @options = options
      @messenger = messenger
    end


    def run command
      SubProcess::Shell.open do | shell |
        shell.on_stdout do | line |
          handle_stdout line
        end
        shell.on_stderr do | line |
          handle_stderr line
        end
        shell.on_failure do
          raise "'#{ command }' failed."
        end
        shell.exec command, { "LC_ALL" => "C" } unless @options[ :dry_run ]

        # Returns an instance of SubProcess::Shell as a return value from
        # this block, in order to get child status.
        shell
      end
    end


    ############################################################################
    private
    ############################################################################


    def handle_stdout message
      stdout.puts message
      Lucie::Log.debug message
    end


    def handle_stderr message
      stderr.puts message
      Lucie::Log.error message
    end


    def stdout
      @messenger || $stdout
    end


    def stderr
      @messenger || $stderr
    end
  end
end


def sh_exec command
  Lucie::Shell.new.run command
end
