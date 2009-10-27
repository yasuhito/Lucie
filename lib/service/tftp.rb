require "configuration"
require "lucie/io"
require "lucie/utils"
require "nfsroot"


class Service
  class Tftp < Service
    include Lucie::IO
    include Lucie::Utils


    config "/etc/default/tftpd-hpa"
    prerequisite "syslinux"
    prerequisite "tftpd-hpa"


    def self.pxe_directory
      File.join Configuration.tftp_root, "pxelinux.cfg"
    end


    def setup_nfsroot nodes, installer, inetd_conf = "/etc/inetd.conf"
      return if nodes.empty?
      info "Setting up tftpd ..."
      nodes.each do | each |
        create_pxe_nfsroot_files_for each, installer
      end
      setup installer.kernel, inetd_conf
    end


    def setup_localboot node
      create_pxe_localboot_files_for node
    end


    def remove node
      remove_pxe_file_of node.mac_address
    end


    def reset_all
      Dir.glob( Tftp.pxe_directory + "/*" ).each do | each |
        write_file each, pxe_local_boot_config, @options.merge( :sudo => true ), @messenger
      end
    end


    ############################################################################
    private
    ############################################################################


    def setup kernel, inetd_conf
      setup_pxe kernel
      reconfigure_inetd inetd_conf
      reconfigure_tftpd
      restart
    end


    def setup_pxe kernel
      run "sudo cp /usr/lib/syslinux/pxelinux.0 #{ Configuration.tftp_root }", @options, @messenger
      run "sudo cp #{ kernel } #{ File.join( Configuration.tftp_root, installer_kernel ) }", @options, @messenger
    end


    def reconfigure_tftpd
      unless tftpd_configured?
        write_file @@config, tftpd_default, @options.merge( :sudo => true ), @messenger
      end
    end


    def create_pxe_nfsroot_files_for node, installer
      make_pxe_directory
      write_file pxe_config_file( node.mac_address ), pxe_nfsroot_config( node, installer ), @options.merge( :sudo => true ), @messenger
    end


    def make_pxe_directory
      unless File.directory?( Tftp.pxe_directory )
        run "sudo mkdir -p #{ Tftp.pxe_directory }", @options, @messenger
      end
    end


    def create_pxe_localboot_files_for node
      write_file pxe_config_file( node.mac_address ), pxe_local_boot_config, @options.merge( :sudo => true ), @messenger
    end


    def remove_pxe_file_of mac
      run "sudo rm -f #{ pxe_config_file( mac ) }", @options, @messenger
    end


    def installer_kernel
      "lucie"
    end


    # tftpd status #############################################################


    def tftpd_configured?
      return false unless FileTest.exists?( @@config )
      return false unless tftpd_run_as_daemon?
      return false unless tftpd_commandline_options_are_valid?
      true
    end


    def tftpd_run_as_daemon?
      IO.read( @@config ).split( "\n" ).each do | each |
        return true if /^RUN_DAEMON=(yes|"yes")$/=~ each
      end
      false
    end


    def tftpd_commandline_options_are_valid?
      IO.read( @@config ).split( "\n" ).each do | each |
        if /^OPTIONS=(.*)$/=~ each
          # -l option: Run the server in standalone (listen) mode.
          # -s option: Change root directory on startup.
          return ( $1 == %{"-v -l -s /var/lib/tftpboot"} )
        end
      end
    end


    # tftpd and pxe configuration snippets #####################################


    def pxe_config_file mac
      File.join Tftp.pxe_directory, pxe_mac_file( mac )
    end


    def tftpd_default
      return <<-EOF
RUN_DAEMON="yes"
OPTIONS="-v -l -s #{ Configuration.tftp_root }"
EOF
    end


    # [TODO] Add comments for 'append' option.
    # [???] idle=poll pci=noacpi nobiospnp noapic nolapic
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


    # inetd ####################################################################


    def reconfigure_inetd inetd_conf
      if tftpd_boot_from_inetd( inetd_conf )
        disable_inetd_conf
      end
    end


    def tftpd_boot_from_inetd inetd_conf
      begin
        IO.read( inetd_conf ).split( "\n" ).each do | each |
          return true if /^tftp\s+/=~ each
        end
      rescue Errno::ENOENT
        return false if @options[ :dry_run ]
        raise $!
      end
      false
    end


    def disable_inetd_conf
      run "sudo /usr/sbin/update-inetd --disable tftp", @options, @messenger
      run "sudo kill -HUP `cat /var/run/inetd.pid`", @options, @messenger
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
