module SubProcess
  class IoHandlerThread < Thread
    def initialize io, method, &block
      super( io, method ) do | io, method |
        while io.gets do
          method.call $LAST_READ_LINE.chomp
        end
      end
      self.priority = -10
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

