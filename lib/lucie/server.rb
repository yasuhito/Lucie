require "rubygems"

require "facter"
require "network_interfaces"


module Lucie
  class Server
    def self.architecture
      arch_command = "dpkg --print-architecture"
      if system( "#{ arch_command } 2> /dev/null 1> /dev/null" )
        `#{ arch_command }`.chomp
      else
        "i386"
      end
    end


    def self.ip_address_for nodes, interfaces = NetworkInterfaces
      subnet, netmask = nodes.first.net_info
      nic = interfaces.select do | each |
        each.subnet == subnet and each.netmask == netmask
      end.first
      raise "Cannot determine suitable network interface for installation" unless nic
      nic.ip_address
    end


    def self.domain
      my_domain = Facter.value( "domain" )
      unless my_domain
        raise "Cannot resolve Lucie server's domain name."
      end
      my_domain
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
