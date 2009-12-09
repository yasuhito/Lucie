require "boot-sequence-tracker/common-re"


class BootSequenceTracker
  module DhcpdRE
    include CommonRE


    def dhcpdiscover_RE node
      /dhcpd: DHCPDISCOVER from #{ mac_RE node }/
    end


    def dhcpoffer_RE node
      /dhcpd: DHCPOFFER on #{ ip_RE node } to #{ mac_RE node }/
    end


    def dhcprequest_RE node
      /dhcpd: DHCPREQUEST for #{ ip_RE node } .* from #{ mac_RE node }/
    end


    def dhcpack_RE node
      /dhcpd: DHCPACK on #{ ip_RE node } to #{ mac_RE node }/
    end


    def mac_RE node
      Regexp.escape node.mac_address.downcase
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
