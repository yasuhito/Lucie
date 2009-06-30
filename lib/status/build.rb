require "status/common"


module Status
  class Build < Common
    base_name "build_status"


    def never_built?
      read_latest_status.nil?
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
