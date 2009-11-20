require "lucie/debug"


module Lucie
  module Logger
    class Updator
      include Lucie::Debug


      def initialize debug_options
        @debug_options = debug_options
      end


      def method_missing method, *args # :nodoc:
        stdout.puts *args
      end
    end
  end
end

