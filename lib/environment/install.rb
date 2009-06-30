require "network_interfaces"
require "service"


module Environment
  class Install
    def initialize options, messenger, configs = {}
      @options = options
      @messenger = messenger
      @configs = configs
    end


    def start node, installer, interfaces
      setup node, installer, interfaces
      yield
      teardown node, installer
    end


    ############################################################################
    private
    ############################################################################


    def setup node, installer, interfaces
      installer.build lucie_server_ipaddress_for( node, interfaces ), @options, @messenger
      Service::Tftp.new( @options, @messenger ).setup_nfsroot [ node ], installer, @configs[ :tftpd ]
      Service::Nfs.new( @options, @messenger ).setup [ node ], installer
      Service::Dhcp.new( @options, @messenger ).setup [ node ], interfaces
    end


    def teardown node, installer
      Service::Tftp.new( @options, @messenger ).setup_localboot node
    end


    # helper methods ###########################################################


    def lucie_server_ipaddress_for node, interfaces
      subnet, netmask = node.net_info
      ( interfaces || NetworkInterfaces ).select do | each |
        each.subnet == subnet and each.netmask == netmask
      end.first.ip_address
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
