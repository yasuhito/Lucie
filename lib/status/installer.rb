require "status/common"


module Status
  class Installer < Common
    base_name "installer_status"


    def install_id
      /install-(\d+)/=~ File.basename( @path )
      $1.to_i
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
