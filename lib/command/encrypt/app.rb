require "command/app"
require "lucie/utils"


module Command
  module Encrypt
    class App < Command::App
      include Lucie::Utils


      def initialize argv = ARGV, debug_options = {}
        @debug_options = debug_options
        super argv, @debug_options
        @global_options.check_mandatory_options
      end


      def main input
        if @global_options.password
          run %{openssl enc -pass pass:"#{ @global_options.password }" -e -aes256 < #{ input }}, @debug_options
        else
          run %{openssl enc -e -aes256 < #{ input }}, @debug_options
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
