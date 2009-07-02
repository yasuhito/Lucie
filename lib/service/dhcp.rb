require "rubygems"

require "facter"
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
      return if all_subnets( nodes ) == {}
      generate_config_file nodes, interfaces
      restart
    end


    def disable
      run "sudo rm -f #{ @@config }", @options, @messenger
      run 'sudo /etc/init.d/dhcp3-server stop', @options, @messenger
    end


    ############################################################################
    private
    ############################################################################


    def restart
      run "sudo /etc/init.d/dhcp3-server restart", @options, @messenger
    end


    def dhcpd_config nodes, interfaces
      <<-EOF
option domain-name "#{ domain }";

#{ subnet_entries( nodes, interfaces ) }
EOF
    end


    def backup_config_file
      run( "sudo mv -f #{ @@config } #{ @@config }.old", @options, @messenger ) if FileTest.exists?( @@config )
    end


    def generate_config_file nodes, interfaces
      @options[ :sudo ] = true
      backup_config_file
      write_file @@config, dhcpd_config( nodes, interfaces ), @options, @messenger
    end


    def subnet_entries nodes, interfaces
      entries = ''
      all_subnets( nodes ).each_pair do | netinfo, nodes |
        entries += subnet_entry( netinfo, broadcast_address( nodes.first ), nodes, interfaces )
      end
      entries
    end


    def broadcast_address node
      Network.broadcast_address node.ip_address, node.netmask_address
    end


    def subnet_entry netinfo, broadcast, nodes, interfaces
      subnet, netmask = netinfo
      return <<-EOF
subnet #{ subnet } netmask #{ netmask } {
  option broadcast-address #{ broadcast };
  deny unknown-clients;

  next-server #{ Lucie::Server.ip_address_for( nodes, interfaces ) };
  filename "pxelinux.0";

#{ host_entries( nodes ) }
}
EOF
    end


    #
    # returns all the subnet and netmask addresses used by nodes.
    #
    # return value:
    #   a Hash of [ network_address, netmask_address ] => [ node1, node2, ... ]
    #
    def all_subnets nodes
      subnets = Hash.new( [] )
      nodes.each do | each |
        subnets[ each.net_info ] = subnets[ each.net_info ].push( each )
      end
      subnets
    end


    def domain
      my_domain = Facter.value( "domain" )
      unless my_domain
        raise "Cannot resolve Lucie server's domain name."
      end
      my_domain
    end


    def next_server subnet, netmask, interfaces
      i = interface_with( subnet, netmask, interfaces ).first
      return i.ip_address if i
      raise "Cannot find network interface for subnet = '#{ subnet }', netmask = '#{ netmask }'"
    end


    def interface_with subnet, netmask, interfaces
      interfaces.select do | each |
        each.subnet == subnet and each.netmask == netmask
      end
    end


    def host_entries nodes
      entries = ''
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
