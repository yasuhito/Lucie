#
# tftp.rb - setups TFTP server
#
# methods:
#   Tftp.setup - generates network boot configuration
#   Tftp.disable - disables network boot
#   Tftp.remove! - removes network boot configuration
#


require 'net/tftp'
require 'popen3/shell'


class Tftp
  def self.setup nodes, installer_name
    self.new.__send__ :setup, nodes, installer_name
  end


  def self.disable node_name
    self.new.__send__ :disable, node_name
  end


  def self.remove! nodes
    self.new.__send__ :remove!, nodes
  end


  ################################################################################
  private
  ################################################################################


  def setup nodes, installer_name
    test_tftpd_is_installed
    setup_pxe nodes, installer_name
    setup_tftpd
  end


  def disable node_name
    test_tftpd_is_installed
    disable_pxe node_name
  end


  def remove! node_name
    test_tftpd_is_installed
    remove_pxe node_name
  end


  def test_tftpd_is_installed
    unless tftpd_is_installed
      raise 'tftpd-hpa package is not installed. Please install first.'
    end
  end


  def setup_tftpd
    File.open( tftpd_default_config, 'w' ) do | file |
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


  def tftpd_default_config
    '/etc/default/tftpd-hpa'
  end


  def setup_pxe nodes, installer_name
    nodes.each do | each |
      node = node_named( each )

      # [???] use Installer.read?
      if Installer.new( installer_name ).last_complete_build_status == 'never_built'
        raise "Installer '#{ installer_name }' is never built."
      end

      unless File.directory?( File.dirname( pxe_config_file( node.mac_address ) ) )
        FileUtils.mkdir_p File.dirname( pxe_config_file( node.mac_address ) )
      end

      File.open( pxe_config_file( node.mac_address ), 'w' ) do | file |
        file.print <<-EOF
default lucie

label lucie
kernel #{ installer_name }
append ip=dhcp devfs=nomount root=/dev/nfs nfsroot=#{ Nfsroot.path( installer_name ) },v2,rsize=32768,wsize=32768 hostname=#{ node.name }
EOF
      end
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


  def remove_pxe node_name
    FileUtils.rm pxe_config_file( node_named( node_name ).mac_address ), :force => true
  end


  def tftpd_is_installed
    File.exists? '/etc/init.d/tftpd-hpa'
  end


  def node_named node_name
    node = Nodes.find( node_name )
    unless node
      raise "Node '#{ node_name }' is not added or enabled yet."
    end
    node
  end


  def tftpd_is_down
    begin
      Net::TFTP.open( 'localhost' ).getbinary( 'NO_SUCH_FILE', StringIO.new )
    rescue Net::TFTPTimeout
      return true
    rescue
      # Failed to getbinary. do nothing.
      nil
    end
    return false
  end


  def pxe_config_file mac_address
    File.join Configuration.tftp_root, 'pxelinux.cfg', "01-#{ mac_address.gsub( ':', '-' ).downcase }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
