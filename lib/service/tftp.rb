#
# = tftp.rb: TFTP daemon configurator for PXE boot
#
# Author:: Yasuhito TAKAMIYA
#
# == Description
#
# tftp.rb defines several methods to
# * enabling network boot with nfsroot
# * enabling localboot
# * removing nodes from PXE boot environment
#
# == See also
#
# * http://lucie.is.titech.ac.jp/trac/lucie/ticket/93
# * http://lucie.is.titech.ac.jp/trac/lucie/ticket/225
#


require "configuration"
require "lucie/io"
require "lucie/mutex"
require "lucie/utils"
require "nfsroot"


class Service
  class Tftp < Service
    include Lucie::IO
    include Lucie::Mutex
    include Lucie::Utils


    config "/etc/default/tftpd-hpa"
    prerequisite "syslinux"
    prerequisite "tftpd-hpa"


    def self.pxe_directory
      File.join Configuration.tftp_root, 'pxelinux.cfg'
    end


    def setup_nfsroot nodes, installer, config = @@config, inetd_conf = nil
      info "Setting up tftpd ..."
      nodes.each do | each |
        create_pxe_nfsroot_files_for each, installer
      end
      run "sudo cp /usr/lib/syslinux/pxelinux.0 #{ Configuration.tftp_root }", @options, @messenger
      run "sudo cp #{ installer.kernel } #{ File.join( Configuration.tftp_root, installer_kernel ) }", @options, @messenger
      setup_tftpd( config, inetd_conf ) unless nodes.empty?
    end


    def setup_localboot node, config = @@config, inetd_conf = nil
      create_pxe_localboot_files_for node
      setup_tftpd config, inetd_conf
    end


    def remove node
      remove_pxe_file_of node.mac_address
    end


    ############################################################################
    private
    ############################################################################


    def setup_tftpd config, inetd_conf
      synchronize do
        restart if reconfigure_inetd( inetd_conf ) or reconfigure_tftpd( config )
      end
    end


    def reconfigure_inetd inetd_conf
      if tftpd_boot_from_inetd( inetd_conf )
        disable_inetd_conf
        return true
      end
      false
    end


    def reconfigure_tftpd config
      if tftpd_not_configured( config )
        write_file config, tftpd_default, @options, @messenger
        return true
      end
      false
    end


    def disable_inetd_conf
      run "sudo /usr/sbin/update-inetd --disable tftp", @options, @messenger
      run "sudo kill -HUP `cat /var/run/inetd.pid`", @options, @messenger
    end


    def tftpd_default
      return <<-EOF
RUN_DAEMON="yes"
OPTIONS="-v -l -s #{ Configuration.tftp_root }"
EOF
    end


    def tftpd_not_configured config
      return true unless FileTest.exists?( config )
      return true unless tftpd_run_as_daemon?( config )
      return true unless tftpd_commandline_options_are_valid?( config )
    end


    def tftpd_boot_from_inetd inetd_conf
      inetd_conf and inetd_conf.split( "\n" ).each do | each |
        return true if /^tftp\s+/=~ each
      end
      false
    end


    def tftpd_run_as_daemon? config
      IO.read( config ).split( "\n" ).each do | each |
        return true if /^RUN_DAEMON=(yes|"yes")$/=~ each
      end
      false
    end


    def tftpd_commandline_options_are_valid? config
      IO.read( config ).split( "\n" ).each do | each |
        if /^OPTIONS=(.*)$/=~ each
          # -l option: Run the server in standalone (listen) mode.
          # -s option: Change root directory on startup.
          return ( $1 == %{"-v -l -s /var/lib/tftpboot"} )
        end
      end
    end


    def restart
      run "sudo /etc/init.d/tftpd-hpa restart", @options, @messenger
    end


    def create_pxe_nfsroot_files_for node, installer
      @options[ :sudo ] = true
      make_pxe_directory
      write_file pxe_config_file( node.mac_address ), pxe_nfsroot_config( node, installer ), @options, @messenger
    end


    def make_pxe_directory
      unless File.directory?( Tftp.pxe_directory )
        run "sudo mkdir -p #{ Tftp.pxe_directory }", @options, @messenger
      end
    end


    def create_pxe_localboot_files_for node
      @options[ :sudo ] = true
      write_file pxe_config_file( node.mac_address ), pxe_local_boot_config, @options, @messenger
    end


    # [TODO] Add comments for 'append' option.
    def pxe_nfsroot_config node, installer
      return <<-EOF
default lucie

label lucie
kernel #{ installer_kernel }
append ip=dhcp devfs=nomount root=/dev/nfs nfsroot=#{ Nfsroot.path( installer ) },v2,rsize=32768,wsize=32768 hostname=#{ node.name } irqpoll
EOF
    end


    def pxe_local_boot_config
      return <<-EOF
default local

label local
localboot 0
EOF
    end


    def remove_pxe_file_of mac
      run "sudo rm -f #{ pxe_config_file( mac ) }", @options, @messenger
    end


    def pxe_config_file mac
      File.join Tftp.pxe_directory, pxe_mac_file( mac )
    end


    def installer_kernel
      "lucie"
    end


    #
    # PXELINUX will search for the config file using the hardware type
    # (using its ARP type code) and address, all in lower case
    # hexadecimal with dash separators; for example, for an Ethernet
    # (ARP type 1) with address 88:99:AA:BB:CC:DD it would search for
    # the filename 01-88-99-aa-bb-cc-dd.
    #
    # See also /usr/share/doc/syslinux/pxelinux.txt.gz included in
    # syslinux debian package.
    #
    def pxe_mac_file mac
      "01-#{ mac.gsub( ':', '-' ).downcase }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
