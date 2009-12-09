require "boot-sequence-tracker/common-re"


class BootSequenceTracker
  class NfsdRE < CommonRE
    def nfs_mount_re
      /mountd\[\d+\]: authenticated mount request from #{ ip_re }/
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
