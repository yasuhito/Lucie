class Dhcp
  def self.setup installer_name
    config_file = "/etc/dhcp3/dhcpd.conf.#{ installer_name }_example"

    if /(\S+)/=~ `hostname -d`
      domain_name = $1
    else
      raise "Cannnot resolve Lucie server's domain name."
    end

    if /(\d{1,3}\.\d{1,3}.\d{1,3}\.\d{1,3})/=~ `host #{ `hostname` }`
      next_server = $1
    else
      raise "Cannnot resolve Lucie server's IP address."      
    end

    host_entries = ''
    nodes = Nodes.load_enabled( installer_name ).collect do | each |
      if /(\d{1,3}\.\d{1,3}.\d{1,3}\.\d{1,3})/=~ `host #{ each.name }`
        ip_address = $1
      else
        raise "Cannnot resolve host '#{ each.name }' IP address."
      end

      host_entries += <<-EOF
  host #{ each.name } {
    hardware ethernet #{ each.mac_address };
    fixed-address #{ ip_address };
  }
EOF
      each.name
    end.join( "\n" )

    File.open( config_file, 'w' ) do | file |
      file.puts <<-EOF
option domain-name "#{ domain_name }";
default-lease-time 600;
max-lease-time 7200;

### REPLACE with your network configuration ###
subnet 192.168.1.0 netmask 255.255.255.0 {
  option broadcast-address 192.168.1.255;
###############################################

  next-server #{ next_server };
  fiilename "pxelinux.0";

#{host_entries}
}
EOF
    end

    puts "File #{ config_file } generated SUCCESFULLY"
  end
end
