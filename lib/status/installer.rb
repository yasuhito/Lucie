require "status/common"


module Status
  class Installer < Common
    attr_reader :path

    base_name "installer_status"


    def install_id
      /install-(\d+)/=~ File.basename( @path )
      $1.to_i
    end


    def label
      File.basename @path
    end


    def broken?
      to_s.empty?
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
