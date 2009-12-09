require "boot-sequence-tracker/common-re"


class BootSequenceTracker
  module NfsdRE
    include CommonRE


    def nfsroot_mount_RE node
      /mountd\[\d+\]: authenticated mount request from #{ ip_RE node }/
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
