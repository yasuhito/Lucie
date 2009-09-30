module StopWatch
  def time_to_run &proc
    start = Time.now
    proc.call
    Time.now - start
  end
  module_function :time_to_run
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
