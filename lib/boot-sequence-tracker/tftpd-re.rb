require "boot-sequence-tracker/common-re"


class BootSequenceTracker
  class TftpdRE < CommonRE
    def tftp_kernel_re
      /in\.tftpd\[\d+\]: RRQ from #{ ip_re } filename lucie/
    end


    def tftp_linux_re
      /in\.tftpd\[\d+\]: RRQ from #{ ip_re } filename pxelinux\.0/
    end
    

    def tftp_linux_cfg_re
      /in\.tftpd\[\d+\]: RRQ from #{ ip_re } filename pxelinux\.cfg\/01\-#{ mac_downcase_re }/
    end


    def mac_downcase_re
      Regexp.escape @node.mac_address.downcase.gsub( ":", "-" )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
