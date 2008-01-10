require 'popen3/shell'


class Tftp
  def self.setup node_name, installer_name
    self.new.setup node_name, installer_name
  end


  def self.disable node
    self.new.disable node
  end


  attr_reader :node_name
  attr_reader :installer_name


  def setup node_name, installer_name
    @node_name = node_name
    @installer_name = installer_name

    setup_pxe
    setup_tftpd
  end


  def disable node
    disable_pxe node
    setup_tftpd
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


  def disable_pxe node
    unless File.directory?( File.dirname( pxe_config_file( node.mac_address ) ) )
      FileUtils.mkdir_p File.dirname( pxe_config_file( node.mac_address ) )
    end
    File.open( pxe_config_file( node.mac_address ), 'w' ) do | file |
      file.print <<-EOF
default local

label local
localboot 0
EOF
    end
  end


  def setup_tftpd
    File.open( '/etc/default/tftpd-hpa', 'w' ) do | file |
      file.puts 'RUN_DAEMON=yes'
      file.puts "OPTIONS=\"-l -s #{ Configuration.tftp_root }\""
    end

    # HACK: /etc/init.d/tftpd-hpa restart does not work correctly
    sh_exec '/etc/init.d/tftpd-hpa stop' rescue nil
    sh_exec '/etc/init.d/tftpd-hpa start'
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
