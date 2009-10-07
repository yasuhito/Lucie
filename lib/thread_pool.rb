require 'thread'


class ThreadPool
  def initialize
    @pool = []
    @waiting = []
    @pool_mutex = Mutex.new
    @pool_cv = ConditionVariable.new
    @max_size = 255
  end


  def dispatch *args
    Thread.new do
      # Wait for space in the pool
      @pool_mutex.synchronize do
        while @pool.size >= @max_size
          $stderr.puts "Pool is full; waiting to run #{ args.join( ',' ) }..." if $DEBUG
          # Sleep until some other thread calls @pool_cv.signal.
          @waiting << Thread.current
          @pool_cv.wait @pool_mutex
          @waiting.delete Thread.current
        end
      end

      begin
        @pool << Thread.current
        yield( *args )
      rescue => e
        $stderr.puts $!.to_str
        $!.backtrace.each do | each |
          $stderr.puts each
        end
      ensure
        @pool_mutex.synchronize do
          # Remove the thread from the pool.
          @pool.delete Thread.current
          # Signal the next waiting thread that there's a space in the pool.
          @pool_cv.signal
        end
      end
    end
  end

 
  def synchronize
    @pool_mutex.synchronize do
      yield
    end
  end


  def wait
    @pool_mutex.synchronize do
      @pool_cv.wait @pool_mutex
    end
  end


  def killall
    ( @pool + @waiting ).each do | each |
      each.kill
    end
  end


  def shutdown 
    @pool_mutex.synchronize do
      until @pool.empty?
        @pool_cv.wait @pool_mutex
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
