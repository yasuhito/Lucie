require "boot-sequence-tracker/common-re"


class BootSequenceTracker
  class DhcpdRE < CommonRE
    def dhcp_discover_re
      /dhcpd: DHCPDISCOVER from #{ mac_re }/
    end


    def dhcp_offer_re
      /dhcpd: DHCPOFFER on #{ ip_re } to #{ mac_re }/
    end


    def dhcp_request_re
      /dhcpd: DHCPREQUEST for #{ ip_re } .* from #{ mac_re }/
    end


    def dhcp_ack_re
      /dhcpd: DHCPACK on #{ ip_re } to #{ mac_re }/
    end


    def mac_re
      Regexp.escape @node.mac_address.downcase
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
