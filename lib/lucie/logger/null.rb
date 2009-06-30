module Lucie
  module Logger
    class Null # :nodoc:
      def method_missing method, *args
        # do nothing.
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:


