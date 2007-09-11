require 'facter'
require 'ftools'
require 'resolv'


class Dhcp
  def self.setup installer_name, ip_address, netmask_address
    self.new.setup installer_name, ip_address, netmask_address
  end


  attr_reader :installer_name


  def setup installer_name, ip_address, netmask_address
    @installer_name = installer_name

    File.copy config_file, config_file + '.orig'
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
    system '/etc/init.d/dhcp3-server restart'
  end


  def domain
    my_domain = Facter.value( 'domain' )
    unless my_domain
      raise "Cannnot resolve Lucie server's domain name."
    end
    return my_domain
  end


  def ipaddress
    my_ipaddress = Facter.value( 'ipaddress' )
    unless my_ipaddress
      raise "Cannnot resolve Lucie server's IP address."
    end
    return my_ipaddress
  end


  def node_ipaddress name
    address = Resolv::Hosts.new.getaddress( name )
    unless address
      raise "Cannnot resolve host '#{ name }' IP address."
    end
    return address
  end


  private


  def host_entries
    entries = ''
    Nodes.load_enabled( installer_name ).each do | each |
      entries += <<-EOF
  host #{ each.name } {
    hardware ethernet #{ each.mac_address };
    fixed-address #{ node_ipaddress( each.name ) };
  }
EOF
    end
    return entries
  end


  def config_file
    return '/etc/dhcp3/dhcpd.conf'
  end
end
