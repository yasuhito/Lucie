#
# network_interfaces.rb - A simple wrapper class for ifconfig.rb
#
# Usage:
#
#   NetworkInterfaces.each do | each |
#     p each.ipaddress
#     p each.subnet
#     p each.netmask
#       ...
#   end
#


require 'ifconfig'


class NetworkInterfaces
  ifconfig = IfconfigWrapper.new.parse
  @@interfaces = ifconfig.interfaces.collect do | each |
    interface = ifconfig[ each ]

    def interface.netmask
      networks[ 'inet' ].mask
    end

    def interface.ipaddress
      addresses( 'inet' ).to_s
    end

    def interface.subnet
      Network.network_address( ipaddress, netmask )
    end

    interface
  end


  def self.method_missing method, *args, &block
    @@interfaces.__send__ method, *args, &block
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
