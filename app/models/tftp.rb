class Tftp
  def self.setup node_name, installer_name
    nfsroot = File.expand_path( "#{ RAILS_ROOT }/installers/#{ installer_name }/nfsroot" )

    Nodes.load_enabled( installer_name ).each do | each |
      next if each.name != node_name
      config_file = "/srv/tftp/lucie/pxelinux.cfg/01-#{ each.mac_address.gsub( ':', '-' ).downcase }"

      File.open( config_file, 'w' ) do | file |
        file.print <<-EOF
default lucie

label lucie
kernel vmlinuz-install
append ip=dhcp devfs=nomount root=/dev/nfs nfsroot=#{ nfsroot },v2,rsize=32768,wsize=32768
EOF
      end
      
      puts "File #{ config_file } generated SUCCESFULLY"
    end

    system 'update-inetd --group BOOT --remove "tftp.*/usr/sbin/in.tftpd.*"'
    system 'update-inetd --group BOOT --add "tftp dgram udp wait nobody /usr/sbin/tcpd /usr/sbin/in.tftpd --tftpd-timeout 300 --retry-timeout 5 --mcast-port 1758 --mcast-addr 239.239.239.0-255 --mcast-ttl 1 --maxthread 100 --verbose=5 /srv/tftp/lucie"'
    File.open( '/etc/default/atftpd', 'w' ) do | file |
      file.puts 'USE_INETD=true'
      file.puts "OPTIONS='--daemon --port 69 --tftpd-timeout 300 --retry-timeout 5 --mcast-port 1758 --mcast-addr 239.239.239.0-255 --mcast-ttl 1 --maxthread 100 --verbose=5 /srv/tftp/lucie'"
    end
    if File.exists?( '/etc/init.d/atftpd' )
      system '/etc/init.d/atftpd restart'
    end
  end
end
