class BootSequenceTracker
  class CommonRE
    def initialize node
      @node = node
    end


    def ip_re
      Regexp.escape @node.ip_address
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
