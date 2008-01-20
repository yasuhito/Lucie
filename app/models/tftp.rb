require 'net/tftp'
require 'popen3/shell'


class Tftp
  def self.setup node_name, installer_name
    self.new.setup node_name, installer_name
  end


  def self.disable node_name
    self.new.disable node_name
  end


  def setup node_name, installer_name
    setup_pxe node_name, installer_name
    setup_tftpd
  end


  def disable node_name
    disable_pxe node_name
    setup_tftpd
  end


  def setup_pxe node_name, installer_name
    node = node_named( node_name )

    unless File.directory?( File.dirname( pxe_config_file( node.mac_address ) ) )
      FileUtils.mkdir_p File.dirname( pxe_config_file( node.mac_address ) )
    end
    File.open( pxe_config_file( node.mac_address ), 'w' ) do | file |
      file.print <<-EOF
default lucie

label lucie
kernel vmlinuz-install
append ip=dhcp devfs=nomount root=/dev/nfs nfsroot=#{ nfsroot( installer_name ) },v2,rsize=32768,wsize=32768
EOF
    end
  end


  def disable_pxe node_name
    node = node_named( node_name )

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

    if tftpd_is_down
      sh_exec '/etc/init.d/tftpd-hpa start'
    else
      # [HACK] /etc/init.d/tftpd-hpa restart often fails.
      sh_exec '/etc/init.d/tftpd-hpa stop'
      sleep 2
      sh_exec '/etc/init.d/tftpd-hpa start'
    end
  end


  private


  def node_named node_name
    node = Nodes.find( node_name )
    unless node
      raise "Node '#{ node_name }' is not added or enabled yet."
    end
    return node
  end


  def tftpd_is_down
    begin
      Net::TFTP.open( 'localhost' ).getbinary( 'NO_SUCH_FILE', StringIO.new )
    rescue Net::TFTPTimeout
      return true
    rescue
      return false
    end
    return false
  end


  def pxe_config_file mac_address
    return "#{ Configuration.tftp_root }/pxelinux.cfg/01-#{ mac_address.gsub( ':', '-' ).downcase }"
  end


  # [???] get nfsroot path with Installer#nfsroot?
  def nfsroot installer_name
    return File.join( Configuration.installers_directory, installer_name, 'nfsroot' )
  end
end
