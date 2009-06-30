require "lucie/io"
require "network_interfaces"
require "nfsroot"


class Service
  class Installer < Service
    include Lucie::IO


    def setup nodes, installer
      info "Setting up installer ..."
      return if @options[ :dry_run ]
      unless FileTest.exists?( Nfsroot.path( installer ) )
        installer.build server_ipaddress_for( nodes ), @options, @messenger
      end
    end


    ############################################################################
    private
    ############################################################################


    def server_ipaddress_for nodes
      subnet, netmask = nodes.first.net_info
      NetworkInterfaces.select do | each |
        each.subnet == subnet and each.netmask == netmask
      end.first.ip_address
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
