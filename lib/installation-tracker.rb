class InstallationTracker
  REFRESH_INTERVAL = 1


  def initialize html_logger
    @html_logger = html_logger
  end


  def main_loop
    last_status = {}
    @thread = Thread.start do
      loop do
        updated = false
        sleep REFRESH_INTERVAL
        Nodes.load_all.each do | each |
          if each.status.succeeded?
            updated = true
            @html_logger.update_status each, "ok"
          elsif each.status.failed?
            updated = true
            @html_logger.update_status each, "failed"
          elsif last_status[ each ] != each.status.read
            updated = true
            last_status[ each ] = each.status.read
            @html_logger.update_status each, each.status.read
            @html_logger.next_step each unless /(started|manual reboot)/i=~ each.status.read
          end
        end
        @html_logger.update_html if updated
      end
    end
  end


  def finalize
    @thread.kill if @thread
    Nodes.load_all.each do | each |
      if each.status.succeeded?
        @html_logger.update_status each, "ok"
      elsif each.status.failed?
        @html_logger.update_status each, "failed"
      else
        @html_logger.update_status each, each.status.read
      end
    end
    @html_logger.update_html
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
