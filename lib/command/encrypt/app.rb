require "command/app"
require "lucie/utils"


module Command
  module Encrypt
    class App < Command::App
      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options
        @global_options.check_mandatory_options
      end


      def main input
        if @global_options.password
          run "openssl enc -pass pass:'#{ @global_options.password }' -e -aes256 -in #{ input }"
        else
          run %{openssl enc -e -aes256 -in #{ input }}
        end
      end


      def run command
        SubProcess.create( @debug_options ) do | shell |
          shell.on_stdout do | line |
            $stdout.print line
          end
          shell.on_stderr do | line |
            $stderr.print line
          end
          shell.on_failure do
            raise "'#{ command }' failed."
          end
          $stderr.puts command if verbose
          shell.exec command
        end
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
