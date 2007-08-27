require 'facter'
require 'ftools'
require 'resolv'


class Dhcp
  def self.domain
    domain = Facter.value( 'domain' )
    unless domain
      raise "Cannnot resolve Lucie server's domain name."
    end
    return domain
  end


  def self.ipaddress
    ipaddress = Facter.value( 'ipaddress' )
    unless ipaddress
      raise "Cannnot resolve Lucie server's IP address."
    end
    return ipaddress
  end


  def self.node_ipaddress hosts, name
    node_ipaddress = Resolv::Hosts.new( hosts ).getaddress( name )
    unless node_ipaddress
      raise "Cannnot resolve host '#{ name }' IP address."
    end
    return node_ipaddress
  end


  def self.setup installer_name, ip_address, netmask_address, hosts = '/etc/hosts'
    config_file = '/etc/dhcp3/dhcpd.conf'
    File.copy config_file, config_file + '.orig'

    host_entries = ''
    nodes = Nodes.load_enabled( installer_name ).collect do | each |
      host_entries += <<-EOF
  host #{ each.name } {
    hardware ethernet #{ each.mac_address };
    fixed-address #{ node_ipaddress( hosts, each.name ) };
  }
EOF
      each.name
    end.join( "\n" )

    File.open( config_file, 'w' ) do | file |
      file.puts <<-EOF
option domain-name "#{ domain }";

subnet #{ Network.network_address( ip_address, netmask_address ) } netmask #{ netmask_address } {
  option broadcast-address #{ Network.broadcast_address( ip_address, netmask_address ) };

  next-server #{ ipaddress };
  filename "pxelinux.0";

#{ host_entries }
}
EOF
    end

    puts "File #{ config_file } generated SUCCESFULLY"
    system '/etc/init.d/dhcp3-server restart'
  end
end
