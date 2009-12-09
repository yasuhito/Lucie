class BootSequenceTracker
  module CommonRE
    def ip_RE node
      Regexp.escape node.ip_address
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
