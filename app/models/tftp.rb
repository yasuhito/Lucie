class Tftp
  def self.setup node_name, installer_name
    nfsroot = File.expand_path( "#{ RAILS_ROOT }/installers/#{ installer_name }/nfsroot" )

    Nodes.load_enabled( installer_name ).each do | each |
      next if each.name != node_name
      config_file = "/srv/tftp/lucie/pxelinux.cfg/01-#{ each.mac_address.gsub( ':', '-' ) }"

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
  end
end
