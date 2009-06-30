require "thread"


module Lucie
  module Mutex
    @@mutex = ::Mutex.new


    def synchronize
      @@mutex.synchronize do
        yield
      end
    end
    module_function :synchronize
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
