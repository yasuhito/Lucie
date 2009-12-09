require "boot-sequence-tracker/common-re"


class BootSequenceTracker
  module TftpdRE
    include CommonRE


    def pxekernel_RE node
      /in\.tftpd\[\d+\]: RRQ from #{ ip_RE node } filename lucie/
    end


    def pxelinux_RE node
      /in\.tftpd\[\d+\]: RRQ from #{ ip_RE node } filename pxelinux\.0/
    end
    

    def pxelinux_cfg_RE node
      /in\.tftpd\[\d+\]: RRQ from #{ ip_RE node } filename pxelinux\.cfg\/01\-#{ mac_downcase_RE node }/
    end


    def mac_downcase_RE node
      Regexp.escape node.mac_address.downcase.gsub( ":", "-" )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
