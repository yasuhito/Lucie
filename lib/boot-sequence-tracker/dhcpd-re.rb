class BootSequenceTracker
  class DhcpdRE
    def initialize node
      @ip = Regexp.escape( node.ip_address )
      @mac = Regexp.escape( node.mac_address.downcase )
    end


    def discover
      /dhcpd: DHCPDISCOVER from #{ @mac }/
    end


    def offer
      /dhcpd: DHCPOFFER on #{ @ip } to #{ @mac }/
    end


    def request
      /dhcpd: DHCPREQUEST for #{ @ip } .* from #{ @mac }/
    end


    def ack
      /dhcpd: DHCPACK on #{ @ip } to #{ @mac }/
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
