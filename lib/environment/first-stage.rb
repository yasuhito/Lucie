require "network_interfaces"
require "service"


module Environment
  class FirstStage
    def initialize debug_options
      @debug_options = debug_options
    end


    def start nodes, installer, inetd_conf = "/etc/inetd.conf", interfaces = NetworkInterfaces
      Service::Installer.new( @debug_options ).setup nodes, installer
      Service::Approx.new( @debug_options ).setup installer.package_repository
      Service::Tftp.new( @debug_options ).setup_nfsroot nodes, installer, inetd_conf
      Service::Nfs.new( @debug_options ).setup nodes, installer
      Service::Dhcp.new( @debug_options ).setup nodes, interfaces
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
