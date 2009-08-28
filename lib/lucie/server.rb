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


    def self.ip_address_for nodes, debug_options = {}
      return "LUCIE_SERVER_IP_ADDRESS" if debug_options[ :dry_run ]
      subnet, = ( nodes.respond_to?( :first ) ? nodes.first : nodes ).net_info
      nic = ( debug_options[ :interfaces ] || NetworkInterfaces ).select do | each |
        Network.subnet_includes? each.subnet, subnet
      end.first
      raise "No suitable network interface for installation found" unless nic
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
