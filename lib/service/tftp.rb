require "configuration"
require "lucie/utils"
require "nfsroot"
require "service/tftp/config-local-boot"
require "service/tftp/config-network-boot"


module Service
  class Tftp < Common
    include Lucie::Utils


    config "/etc/default/tftpd-hpa"
    prerequisite "syslinux"
    prerequisite "tftpd-hpa"


    def self.pxe_directory
      File.join Configuration.tftp_root, "pxelinux.cfg"
    end


    def setup_networkboot nodes, installer
      nodes.each do | each |
        make_pxe_directory
        create_pxe_nfsroot_files_for each, installer
      end
      setup( installer ) unless nodes.empty?
    end


    def setup_localboot node
      ConfigLocalBoot.new( node.mac_address, @debug_options ).create
    end


    def remove node
      remove_pxe_file_of node.mac_address
    end


    def reset_all
      ConfigFile.all.each { | each | write( each, ConfigLocalBoot::CONTENT ) }
    end


    ############################################################################
    private
    ############################################################################


    def setup installer
      setup_pxelinux
      setup_pxe_kernel installer.kernel
      reconfigure_inetd
      reconfigure_tftpd
      restart
    end


    def setup_pxelinux
      run "sudo cp /usr/lib/syslinux/pxelinux.0 #{ Configuration.tftp_root }", @debug_options
    end


    def setup_pxe_kernel kernel
      run "sudo cp #{ kernel } #{ File.join( Configuration.tftp_root, ConfigFile::INSTALLER_KERNEL ) }", @debug_options
    end


    def reconfigure_tftpd
      unless tftpd_configured?
        write config_path, ConfigFile.tftpd_default
      end
    end


    def create_pxe_nfsroot_files_for node, installer
      ConfigNetworkBoot.new( node, installer, @debug_options ).create
    end


    def make_pxe_directory
      target = Tftp.pxe_directory
      run "sudo mkdir -p #{ target }", @debug_options unless File.directory?( target )
    end


    def remove_pxe_file_of mac
      run "sudo rm -f #{ ConfigFile.new( mac ).path }", @debug_options
    end


    # tftpd status #############################################################


    def tftpd_configured?
      return false unless FileTest.exists?( config_path )
      return false unless tftpd_run_as_daemon?
      return false unless tftpd_commandline_options_are_valid?
      true
    end


    def tftpd_run_as_daemon?
      IO.read( config_path ).split( "\n" ).each do | each |
        return true if /^RUN_DAEMON=(yes|"yes")$/=~ each
      end
      false
    end


    def tftpd_commandline_options_are_valid?
      IO.read( config_path ).split( "\n" ).each do | each |
        if /^OPTIONS=(.*)$/=~ each
          # -l option: Run the server in standalone (listen) mode.
          # -s option: Change root directory on startup.
          return ( $1 == %{"-v -l -s /var/lib/tftpboot"} )
        end
      end
    end


    # inetd ####################################################################


    def reconfigure_inetd
      disable_inetd_conf if tftpd_boot_from_inetd
    end


    def tftpd_boot_from_inetd
      inetd_conf.split( "\n" ).each do | each |
        return true if /^tftp\s+/=~ each
      end
      false
    end


    def inetd_conf
      IO.read( @debug_options[ :inetd_conf ] || "/etc/inetd.conf" )
    end


    def disable_inetd_conf
      run "sudo /usr/sbin/update-inetd --disable tftp", @debug_options
      run "sudo kill -HUP `cat /var/run/inetd.pid`", @debug_options
    end


    # util #####################################################################


    def write path, content
      write_file path, content, @debug_options.merge( :sudo => true )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
