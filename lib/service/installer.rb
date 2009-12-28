require "lucie/server"


module Service
  #
  # A controller class of nfsroot service. This class automatically
  # (re-)builds nfsroot directory.
  #
  class Installer < Common
    #
    # Builds an +installer+ if need be. Lucie server's IP address is
    # specified with +lucie_server_ip_address+.
    #
    def setup installer, lucie_server_ip_address
      installer.build lucie_server_ip_address, @debug_options
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
