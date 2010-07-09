#
# Handles standard IOs of sub-process.
#
class SubProcess::IoHandlerThread # :nodoc:
  def initialize io, method
    @io = io
    @method = method
  end


  def start
    Thread.new( @io, @method ) do | io, method |
      while io.gets do
        method.call $LAST_READ_LINE
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

