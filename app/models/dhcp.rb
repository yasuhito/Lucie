#
# dhcp.rb - setups dhcp server
#
# methods:
#
#   Dhcp.setup - setups dhcp server
#


require 'facter'
require 'ftools'
require 'ifconfig'
require 'popen3/shell'
require 'resolv'


class Dhcp
  #
  # automagically generates /etc/dhcp3/dhcpd.conf and restarts dhcp
  # server
  #
  def self.setup
    self.new.__send__ :setup
  end


  ################################################################################
  private
  ################################################################################


  def setup
    if all_subnets == {}
      # [???] emit warning?
      return
    end

    unless dhcpd_installed
      raise 'dhcp3-server package is not installed. Please install first.'
    end

    generate_config_file

    begin
      sh_exec '/etc/init.d/dhcp3-server restart'
    rescue
      # [???] revert to original dhcpd.conf?
      raise 'dhcpd server failed to start - check syslog for diagnostics.'
    end
  end


  def generate_config_file
    File.copy config_file, config_file + '.orig'
    File.open( config_file, 'w' ) do | file |
      all_subnets.each_pair do | netinfo, nodes_in_subnet |
        subnet = netinfo[ 0 ]
        netmask = netinfo[ 1 ]

        first_node = nodes_in_subnet.first
        router = first_node.gateway_address
        broadcast = Network.broadcast_address( first_node.ip_address, first_node.netmask_address )

        file.puts <<-EOF
option domain-name "#{ domain }";

subnet #{ subnet } netmask #{ netmask } {
  option routers #{ router };
  option broadcast-address #{ broadcast };
  deny unknown-clients;

  next-server #{ next_server( subnet, netmask ) };
  filename "pxelinux.0";

#{ host_entries( nodes_in_subnet ) }
}
EOF
      end
    end
  end


  def dhcpd_installed
    File.exists? '/usr/sbin/dhcpd3'
  end


  #
  # returns all the subnet and netmask addresses used by enabled nodes.
  #
  # return value:
  #   a hash of [ network_address, netmask_address ] => [ node1, node2, ... ]
  #
  def all_subnets
    sn = Hash.new( [] )

    Nodes.load_all.select do | each |
      each.enable?
    end.each do | each |
      key = [ Network.network_address( each.ip_address, each.netmask_address ), each.netmask_address ]
      sn[ key ] = sn[ key ].push( each )
    end
    sn
  end


  def domain
    my_domain = Facter.value( 'domain' )
    unless my_domain
      raise "Cannnot resolve Lucie server's domain name."
    end
    my_domain
  end


  def next_server subnet, netmask
    ifconfig = IfconfigWrapper.new.parse
    ifconfig.interfaces.each do | each |
      if_netmask = ifconfig[ each ].networks[ 'inet' ].mask
      if_ipaddress = ifconfig[ each ].addresses( 'inet' ).to_s
      if_subnet = Network.network_address( if_ipaddress, if_netmask )

      if if_subnet == subnet and if_netmask == netmask
        return if_ipaddress
      end
    end
    raise "Cannnot find network interface for subnet = \"#{ subnet }\", netmask = \"#{ netmask }\""
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


  def config_file
    '/etc/dhcp3/dhcpd.conf'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
