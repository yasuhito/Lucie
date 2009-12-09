require "boot-sequence-tracker/dhcpd-re"
require "boot-sequence-tracker/nfsd-re"
require "boot-sequence-tracker/tftpd-re"


class BootSequenceTracker
  module SyslogRE
    include DhcpdRE
    include NfsdRE
    include TftpdRE
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
