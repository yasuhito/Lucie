class BootSequenceTracker
  class TftpdRE
    def initialize node
      @ip = Regexp.escape( node.ip_address )
      @mac = Regexp.escape( node.mac_address.downcase.gsub( ":", "-" ) )
    end


    def kernel
      /in\.tftpd\[\d+\]: RRQ from #{ @ip } filename lucie/
    end


    def pxelinux
      /in\.tftpd\[\d+\]: RRQ from #{ @ip } filename pxelinux\.0/
    end
    

    def pxelinux_cfg
      /in\.tftpd\[\d+\]: RRQ from #{ @ip } filename pxelinux\.cfg\/01\-#{ @mac }/
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
