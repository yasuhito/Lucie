require "rubygems"

require "lucie/io"
require "lucie/server"
require "lucie/utils"
require "network"
require "network_interfaces"


class Service
  class Dhcp < Service
    include Lucie::IO
    include Lucie::Utils


    config "/etc/dhcp3/dhcpd.conf"
    prerequisite "dhcp3-server"


    def setup nodes, interfaces = NetworkInterfaces
      info "Setting up dhcpd ..."
      return if nodes.empty?
      backup
      write_config nodes, interfaces
      restart
    end


    ############################################################################
    private
    ############################################################################


    def write_config nodes, interfaces
      write_file @@config, dhcpd_conf( nodes, interfaces ), @options.merge( :sudo => true ), @messenger
    end


    # Networking ###############################################################


    def broadcast_address nodes
      node = nodes.first
      Network.broadcast_address node.ip_address, node.netmask_address
    end


    #
    # returns all the subnet and netmask addresses used by nodes.
    #
    # return value:
    #   a Hash of [ network_address, netmask_address ] => [ node1, node2, ... ]
    #
    def subnets nodes
      subnets = Hash.new( [] )
      nodes.each do | each |
        subnets[ each.net_info ] = subnets[ each.net_info ].push( each )
      end
      subnets
    end


    # dhcpd.conf snippets ######################################################


    def dhcpd_conf nodes, interfaces
      <<-EOF
option domain-name "#{ Lucie::Server.domain }";

#{ subnet_entries( nodes, interfaces ) }
EOF
    end


    def subnet_entries nodes, interfaces
      entries = ""
      subnets( nodes ).each_pair do | netinfo, nodes |
        entries += subnet_entry( netinfo, nodes, interfaces )
      end
      entries
    end


    def subnet_entry netinfo, nodes, interfaces
      subnet, netmask = netinfo
      return <<-EOF
subnet #{ subnet } netmask #{ netmask } {
  option broadcast-address #{ broadcast_address( nodes ) };
  deny unknown-clients;

  next-server #{ Lucie::Server.ip_address_for( nodes, :interfaces => interfaces ) };
  filename "pxelinux.0";

#{ host_entries( nodes ) }
}
EOF
    end


    def host_entries nodes
      entries = ""
      nodes.each do | each |
        entries += <<-EOF
  host #{ each.name } {
    hardware ethernet #{ each.mac_address };
    fixed-address #{ each.ip_address };
  }
EOF
      end
      entries
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
