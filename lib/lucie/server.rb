require "network_interfaces"


module Lucie
  class Server
    def self.ip_address_for nodes
      subnet, netmask = nodes.first.net_info
      nic = NetworkInterfaces.select do | each |
        each.subnet == subnet and each.netmask == netmask
      end.first
      raise "Cannot determine suitable network interface for installation" unless nic
      nic.ip_address
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
