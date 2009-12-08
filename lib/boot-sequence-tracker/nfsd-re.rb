class BootSequenceTracker
  class NfsdRE
    def initialize node
      @ip = Regexp.escape( node.ip_address )
    end


    def mount
      /mountd\[\d+\]: authenticated mount request from #{ @ip }/
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
