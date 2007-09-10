require 'lib/popen3/shell'


class Tftp
  def self.setup node_name, installer_name
    self.new.setup node_name, installer_name
  end


  attr_reader :node_name
  attr_reader :installer_name


  def setup node_name, installer_name
    @node_name = node_name
    @installer_name = installer_name

    setup_pxe
    setup_inetd
    setup_atftpd
  end


  def setup_pxe
    node = Nodes.load_enabled( installer_name ).select do | each |
      each.name == node_name
    end
    if node.empty?
      raise "Node '#{ node_name }' is not added or enabled yet."
    end
    node = node.first

    unless File.directory?( File.dirname( pxe_config_file( node.mac_address ) ) )
      FileUtils.mkdir_p File.dirname( pxe_config_file( node.mac_address ) )
    end
    File.open( pxe_config_file( node.mac_address ), 'w' ) do | file |
      file.print <<-EOF
default lucie

label lucie
kernel vmlinuz-install
append ip=dhcp devfs=nomount root=/dev/nfs nfsroot=#{ nfsroot },v2,rsize=32768,wsize=32768
EOF
    end
  end


  def setup_inetd
    sh_exec 'update-inetd --group BOOT --remove "tftp.*/usr/sbin/in.tftpd.*"'
    sh_exec "update-inetd --group BOOT --add \"tftp dgram udp wait nobody /usr/sbin/tcpd /usr/sbin/in.tftpd --tftpd-timeout 300 --retry-timeout 5 --mcast-port 1758 --mcast-addr 239.239.239.0-255 --mcast-ttl 1 --maxthread 100 --verbose=5 #{Configuration.tftp_root}\""
  end


  def setup_atftpd
    File.open( '/etc/default/atftpd', 'w' ) do | file |
      file.puts 'USE_INETD=true'
      file.puts "OPTIONS='--daemon --port 69 --tftpd-timeout 300 --retry-timeout 5 --mcast-port 1758 --mcast-addr 239.239.239.0-255 --mcast-ttl 1 --maxthread 100 --verbose=5 #{Configuration.tftp_root}'"
    end
    if File.exists?( '/etc/init.d/atftpd' )
      sh_exec '/etc/init.d/atftpd restart'
    end
  end


  private


  def pxe_config_file mac_address
    return "#{ Configuration.tftp_root }/pxelinux.cfg/01-#{ mac_address.gsub( ':', '-' ).downcase }"
  end


  # [???] get nfsroot path by Installers::nfsroot?
  def nfsroot
    return File.expand_path( "#{ RAILS_ROOT }/installers/#{ installer_name }/nfsroot" )
  end
end
