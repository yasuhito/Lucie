require "boot-sequence-tracker/dhcpd-re"
require "boot-sequence-tracker/nfsd-re"
require "boot-sequence-tracker/tftpd-re"


class BootSequenceTracker
  module SyslogRE
    RE = { "tftp" => TftpdRE, "dhcp" => DhcpdRE, "nfs" => NfsdRE }


    def method_missing message, node
      re_klass_from( message ).new( node ).__send__ message
    end


    def re_klass_from message
      RE[ message.to_s.split( "_" ).first ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
