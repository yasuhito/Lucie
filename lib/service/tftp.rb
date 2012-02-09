require "configuration"
require "nfsroot"
require "service/inetd"
require "service/tftp/config-file"
require "service/tftp/config-local-boot"
require "service/tftp/config-network-boot"


module Service
  #
  # A configuration generator for TFTP service.
  #
  class Tftp < Common
    config "/etc/default/tftpd-hpa"
    prerequisite "syslinux"
    prerequisite "tftpd-hpa"


    def setup_networkboot nodes, installer
      return if nodes.empty?
      nodes.each do | each |
        maybe_make_pxe_directory
        create_networkboot_file each, installer
      end
      setup installer
    end


    def setup_localboot node
      ConfigLocalBoot.new( node, @debug_options ).create
    end


    def setup_localboot_all
      ConfigFile.all.each do | each |
        sudo_write each, ConfigLocalBoot.content
      end
    end


    ############################################################################
    private
    ############################################################################


    def setup installer
      setup_pxe_for installer
      maybe_reconfigure_inetd
      maybe_reconfigure_tftpd
      restart
    end


    def setup_pxe_for installer
      tftp_root = Configuration.tftp_root
      sudo_run "cp /usr/lib/syslinux/pxelinux.0 #{ tftp_root }", @debug_options
      sudo_run "cp #{ installer.kernel } #{ File.join tftp_root, ConfigFile::INSTALLER_KERNEL }", @debug_options
      sudo_run "cp #{ installer.initrd } #{ tftp_root }", @debug_options
    end


    def maybe_reconfigure_inetd
      Inetd.new( @debug_options ).disable( "tftp" )
    end


    def maybe_reconfigure_tftpd
      sudo_write config_path, ConfigFile.tftpd_default
    end


    def create_networkboot_file node, installer
      ConfigNetworkBoot.new( node, Nfsroot.path( installer ), @debug_options ).create
    end


    def maybe_make_pxe_directory
      target = ConfigFile.pxe_directory
      sudo_run "mkdir -p #{ target }", @debug_options unless File.directory?( target )
    end


    # tftpd status #############################################################


    def tftpd_configured?
      return false unless tftpd_config_file_exists?
      return false unless tftpd_run_as_daemon?
      return false unless tftpd_commandline_options_are_valid?
      true
    end


    def tftpd_config_file_exists?
      FileTest.exists? config_path
    end


    def tftpd_run_as_daemon?
      /^RUN_DAEMON=(yes|"yes")$/=~ tftpd_conf
    end


    def tftpd_commandline_options_are_valid?
      if /^OPTIONS="([^\"]*)"$/=~ tftpd_conf
        # -l option: Run the server in standalone (listen) mode.
        # -s option: Change root directory on startup.
        $1 == "-v -l -s #{ Configuration.tftp_root }"
      end
    end


    def tftpd_conf
      IO.read config_path
    end


    # util #####################################################################


    def sudo_write path, content
      write_file path, content, @debug_options.merge( :sudo => true )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
