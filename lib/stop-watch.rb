#
# Tracks the time to run a block.
#
class StopWatch
  def time_to_run &block
    start
    block.call
    stop
    elapsed
  end


  ##############################################################################
  private
  ##############################################################################


  def start
    @start_time = Time.now
  end


  def stop
    @stop_time = Time.now
  end


  def elapsed
    @stop_time - @start_time
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
