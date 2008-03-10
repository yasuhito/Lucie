require 'facter'
require 'ftools'
require 'popen3/shell'
require 'resolv'


class Dhcp
  def self.setup
    self.new.setup
  end


  def setup
    if subnet == {}
      return
    end

    File.copy config_file, config_file + '.orig'

    File.open( config_file, 'w' ) do | file |
      subnet.each_key do | each |
        first = subnet[ each ].first
        file.puts <<-EOF
option domain-name "#{ domain }";

subnet #{ each[ :naddress ] } netmask #{ each[ :netmask ] } {
  option routers #{ first.gateway_address };
  option broadcast-address #{ Network.broadcast_address( first.ip_address, first.netmask_address ) };
  deny unknown-clients;

  next-server #{ ipaddress };
  filename "pxelinux.0";

#{ host_entries( subnet[ each ] ) }
}
EOF
      end
    end

    begin
      sh_exec '/etc/init.d/dhcp3-server restart'
    rescue
      raise 'dhcpd server failed to start - check syslog for diagnostics.'
    end
  end


  ################################################################################
  private
  ################################################################################


  def subnet
    subnet = Hash.new( [] )
    Nodes.load_all.select do | each |
      each.enable?
    end.each do | each |
      key = { :naddress => Network.network_address( each.ip_address, each.netmask_address ), :netmask => each.netmask_address }
      subnet[ key ] = subnet[ key ].push( each )
    end
    subnet
  end


  def domain
    my_domain = Facter.value( 'domain' )
    unless my_domain
      raise "Cannnot resolve Lucie server's domain name."
    end
    my_domain
  end


  def ipaddress
    my_ipaddress = Facter.value( 'ipaddress' )
    unless my_ipaddress
      raise "Cannnot resolve Lucie server's IP address."
    end
    my_ipaddress
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
    return '/etc/dhcp3/dhcpd.conf'
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
