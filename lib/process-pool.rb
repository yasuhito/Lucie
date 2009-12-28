class ProcessPool
  def initialize debug_options = {}
    @debug_options = debug_options
    @pool = []
  end


  def dispatch node, &block
    if @debug_options[ :dry_run ]
      block.call node
      return
    end
    pid = Kernel.fork do
      block.call node
    end
    @pool << [ pid, node ]
  end


  def shutdown
    return if @debug_options[ :dry_run ]
    @pool.each do | pid, node |
      begin
        hoge, status = Process.waitpid2( pid )
        if status.exitstatus != 0
          raise "Node #{ node.name } failed"
        end
      rescue Errno::ECHILD
        # do nothing
        nil
      end
    end
  end


  def killall
    @pool.each do | pid, node |
      Process.kill "TERM", pid
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
