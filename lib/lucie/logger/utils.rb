require "lucie/debug"
require "lucie/log"


module Lucie
  module Logger
    class Utils
      include Lucie::Debug


      def initialize debug_options
        @debug_options = debug_options
      end


      def debug message
        Lucie::Log.verbose = verbose
        Lucie::Log.debug message
        stderr.puts( message ) if verbose
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
