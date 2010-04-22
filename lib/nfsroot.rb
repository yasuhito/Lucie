#
# Rake task definitions for creating a nfsroot.
#
# Nfsroot.configure defines following rake targets:
#
#  * installer:nfsroot: builds nfsroot.
#  * installer:clobber_nfsroot: clobbers nfsroot directory.
#  * plus, nfsroot base tasks (see NfsrootBase class).
#


require "rubygems"

require "apt"
require "facter"
require "lucie/log"
require "lucie/shell"
require "lucie/utils"
require "nfsroot-base"
require "nodes"
require "rake"
require "rake/tasklib"
require "ssh"
require "sub-process"


class Nfsroot < Rake::TaskLib
  attr_accessor :http_proxy
  attr_accessor :package_repository
  attr_accessor :root_password
  attr_accessor :sources_list
  attr_accessor :suite
  attr_accessor :target_directory

  attr_accessor :dry_run # :nodoc:
  attr_accessor :messenger # :nodoc:
  attr_accessor :verbose # :nodoc:


  def self.path installer
    File.join installer.path, "nfsroot"
  end


  def self.configure &block
    nfsroot = self.new
    block.call nfsroot
    nfsroot.define_tasks
  end


  def initialize
    @distribution = "debian"
    @http_proxy = nil
    @package_repository = "http://cdn.debian.or.jp/debian"
    @root_password = "h29SP9GgVbLHE"
    @suite = "lenny"
  end
  

  # [TODO] check prerequisites
  def define_tasks
    @nfsroot_base = NfsrootBase.configure do | task |
      task.http_proxy = @http_proxy
      task.include = [ "grub", "mercurial", "subversion", "sqlite3", "make", "rsync" ]
      task.package_repository = @package_repository
      task.suite = @suite

      task.dry_run = @dry_run
      task.messenger = @messenger
      task.verbose = @verbose
    end

    directory @target_directory

    namespace "installer" do
      task name => [ "installer:build_nfsroot", "installer:install_nfsroot_kernel" ]

      desc "Build an nfsroot using #{ @nfsroot_base.target }."
      task "build_nfsroot" => [ "installer:clobber_nfsroot", @target_directory, "installer:nfsroot_base" ] do
        begin
          extract_nfsroot_base
          hoaks_packages
          generate_etc_hosts
          upgrade_nfsroot
          generate_live_conf
          add_packages_nfsroot
          set_root_password
          finish_nfsroot
          setup_ssh
          info "nfsroot created on #{ @target_directory }."
        ensure
          umount_dirs
        end
      end

      task "install_nfsroot_kernel" do
        install_kernel_nfsroot
        setup_pxe
      end

      desc "Remove #{ @target_directory }."
      task paste( 'clobber_', name ) do
        if File.exist?( @target_directory )
          info "#{ @target_directory } already exists. Removing #{ @target_directory }"

          # ignore errors when /dev/pts is not mounted.
          run "umount #{ target( '/dev/pts' ) } 2>&1" rescue nil
          run "umount #{ target( '/proc' ) }" rescue nil

          ( Dir.glob( target( '/dev/.??*' ) ) + Dir.glob( target( '/*' ) ) ).each do | each |
            run "rm -rf #{ each }"
          end
          # also remove files nfsroot/.? but not . and ..
          SubProcess::Shell.open do | shell |
            shell.on_stdout do | line |
              run "rm -f #{ line }"
            end
            shell.on_failure do
              # do nothing
            end
            shell.exec "find #{ @target_directory } -xdev -maxdepth 1 ! -type d'"
          end
        end
      end
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def name
    "nfsroot"
  end


  ##############################################################################
  # nfsroot building steps
  ##############################################################################


  def extract_nfsroot_base
    info "Extracting installer base tarball (#{ @nfsroot_base.target }) to #{ @target_directory }."
    run "tar -C #{ @target_directory } -xzf #{ @nfsroot_base.target }"
  end


  # hoaks some packages
  # liloconfig, dump and raidtool2 needs these files
  def hoaks_packages
    info "Modifying nfsroot to avoid errors caused by some packages."
    write_file target( "etc/fstab" ), "#UNCONFIGURED FSTAB FOR BASE SYSTEM"
    touch target( "etc/raidtab" )
    write_file target( "etc/default/ntp-servers" ), 'NTPSERVERS=""'
    mkdir_p target( "var/state" ) unless FileTest.directory?( target( "var/state" ) )
    write_file target( "etc/apt/sources.list" ), "deb #{ @package_repository } #{ suite } main contrib non-free"
  end


  # [???] Support configuration option for adding arbitrary /etc/hosts entries.
  def generate_etc_hosts
    hosts = ip_addresses.collect do | each |
      `getent hosts #{ each }`
    end.join( "\n" )
    write_file target( "etc/hosts" ), hosts
  end


  def upgrade_nfsroot
    info "Upgrading nfsroot."

    if FileTest.file?( "/etc/resolv.conf" )
      run "cp -p /etc/resolv.conf #{ target( 'etc/resolv.conf-lucieserver' ) }"
      run "cp -p /etc/resolv.conf #{ target( 'etc/resolv.conf' ) }"
    end

    run "mount -t proc /proc #{ target( 'proc' ) }"
    # run "mount -t devpts -o rw,gid=5,mode=620 /devpts #{ target( 'dev/pts' ) }"

    AptGet.update apt_option, @messenger
    AptGet.check apt_option, @messenger
    run "rm -rf #{ target( 'etc/apm' ) }"

    mkdir_p target( "/usr/lib/ruby/1.8" )
    run "cp -r #{ Lucie::ROOT }/lib/* #{ target( '/usr/lib/ruby/1.8' )}"

    dpkg_divert "/usr/sbin/update-initramfs"
    run "ln -s /bin/true #{ target '/usr/sbin/update-initramfs' }"

    dpkg_divert "/sbin/start-stop-daemon", "/sbin/discover-modprobe"
    [ target( "sbin/lucie-start-stop-daemon" ), target( "sbin/start-stop-daemon" ) ].each do | each |
      run "cp #{ Lucie::ROOT + "/script/start-stop-daemon" } #{ each }"
      run "chmod +x #{ each }"
    end

    AptGet.apt "-y dist-upgrade", apt_option, @messenger
  end


  def generate_live_conf
    run "cp #{ Lucie::ROOT + '/config/live.conf' } #{ target 'etc' }"
  end


  def add_packages_nfsroot
    info "Adding additional packages to nfsroot."
    info "Adding packages to nfsroot: #{ additional_packages.join( ', ' ) }"
    info "NOTE: Error outputs generated by package installation scripts can be safely ignored."

    run %{rm #{ target( "/usr/share/perl5/Debconf/FrontEnd/Dialog.pm" ) } }
    run %{rm #{ target( "/usr/share/perl5/Debconf/FrontEnd/Readline.pm" ) } }
    run %{rm #{ target( "/usr/share/perl5/Debconf/FrontEnd/Teletype.pm" ) } }

    run %{echo "do_bootloader = No" > #{ target( 'etc/kernel-img.conf' ) }}
    run %{echo "do_initrd = No" >> #{ target( 'etc/kernel-img.conf' ) }}
    run %{echo "warn_initrd = No" >> #{ target( 'etc/kernel-img.conf' ) }}

    AptGet.update apt_option, @messenger
    AptGet.apt( [ "--fix-missing", "install" ] + additional_packages, apt_option, @messenger )
    AptGet.clean apt_option, @messenger
  end


  def additional_packages
    arch = case Lucie::Server.architecture
           when "i386"
             "486"
           when "i686"
             "686"
           else
             Lucie::Server.architecture
           end
    [ "ruby", "reiserfsprogs", "discover", "module-init-tools",
      "udev", "console-tools", "psmisc", "file", "perl-modules",
      "libparse-recdescent-perl", "parted", "facter", "ssh",
      "initramfs-tools", "live-initramfs", "firmware-bnx2",
      "firmware-bnx2x", "aufs-modules-2.6-#{ arch }" ]
  end


  def set_root_password
    run %{echo "root:#{ @root_password }" | chroot #{ @target_directory } chpasswd --encrypted}
    run %{chroot #{ @target_directory } shadowconfig on}
  end


  def finish_nfsroot
    run "rm #{ target( '/etc/mtab' ) } #{ target( '/dev/MAKEDEV' ) }" rescue nil
    run "ln -s /proc/mounts #{ target( '/etc/mtab' ) }"
    unless FileTest.directory?( target( '/var/lib/discover' ) )
      run "mkdir #{ target( '/var/lib/discover' ) }"
    end
    unless FileTest.directory?( target( '/var/discover' ) )
      run "mkdir #{ target( '/var/discover' ) }"
    end
    run "mkdir #{ target( '/etc/sysconfig' ) } #{ target( '/tmp/etc' ) }"
    run "cp -p /etc/resolv.conf #{ target( '/tmp/etc' ) }"
    run "ln -sf /tmp/etc/resolv.conf #{ target( '/etc/resolv.conf' )}"
    run "cp #{ Lucie::ROOT }/script/rcS_lucie #{ target( '/etc/init.d/rcS' ) }"
    run "chmod +x #{ target( '/etc/init.d/rcS' ) }"

    # copy setup-storage and its configuration
    run "cp #{ Lucie::ROOT }/script/list_disks #{ target( '/usr/sbin/list_disks' ) }"
    run "cp #{ Lucie::ROOT }/script/disk-info #{ target( '/usr/sbin/disk-info' ) }"
    run "cp #{ Lucie::ROOT }/script/setup-storage #{ target( '/usr/sbin/setup-storage' ) }"
    run "chmod +x #{ target( '/usr/sbin/list_disks' ) }"
    run "chmod +x #{ target( '/usr/sbin/disk-info' ) }"
    run "chmod +x #{ target( '/usr/sbin/setup-storage' ) }"
    run "cp -r #{ Lucie::ROOT }/vendor/fai/ #{ target( '/usr/share/' )}"

    # copy other installer scripts
    run "cp #{ Lucie::ROOT }/script/setup_password #{ target( '/usr/sbin/setup_password' ) }"
    run "chmod +x #{ target( '/usr/sbin/setup_password' ) }"
    run "cp #{ Lucie::ROOT }/script/setup_grub #{ target( '/usr/sbin/setup_grub' ) }"
    run "chmod +x #{ target( '/usr/sbin/setup_grub' ) }"
    run "cp #{ Lucie::ROOT }/script/setup_network #{ target( '/usr/sbin/setup_network' ) }"
    run "chmod +x #{ target( '/usr/sbin/setup_network' ) }"
    run "cp #{ Lucie::ROOT }/script/setup_ssh #{ target( '/usr/sbin/setup_ssh' ) }"
    run "chmod +x #{ target( '/usr/sbin/setup_ssh' ) }"
    run "cp #{ Lucie::ROOT }/script/mount2dir #{ target( '/usr/sbin/mount2dir' ) }"
    run "chmod +x #{ target( '/usr/sbin/mount2dir' ) }"

    if FileTest.directory?( target( '/var/yp' ) )
      run "ln -s /tmp/binding #{ target( '/var/yp/binding' ) }"
    end
    run %{echo "iface lo inet loopback" > #{ target( '/etc/network/interfaces' ) }}
    run %{echo "*.* /tmp/syslog.log" > #{ target( '/etc/syslog.conf' ) }}
  end


  def install_kernel_nfsroot
    info "Installing kernel on nfsroot."
    if FileTest.exist?( target "/usr/sbin/update-initramfs.distrib" )
      run %{rm #{ target "/usr/sbin/update-initramfs" }}
      run "chroot #{ @target_directory } dpkg-divert --rename --remove /usr/sbin/update-initramfs"
    end
    run "chroot #{ @target_directory } update-initramfs -k all -t -u -v"
  end


  def setup_ssh
    ssh = SSH.new( :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger )
    ssh.setup_ssh_access_to @target_directory
  end


  def setup_pxe
    pxebin = '/usr/lib/syslinux/pxelinux.0'
    tftp_kernel_target = File.join( Configuration.tftp_root, ENV[ 'INSTALLER_NAME' ] || @suite )

    info 'Setting up PXE environment.'
    run "cp -p #{ target '/boot/initrd.img-*' } #{ Configuration.tftp_root }"

    run "cp -p #{ target '/boot/vmlinuz-*' } #{ tftp_kernel_target }"
    run "cp #{ pxebin } #{ Configuration.tftp_root }"
  end


  def umount_dirs
    run "/usr/sbin/chroot #{ @target_directory } dpkg-divert --rename --remove /sbin/discover-modprobe"
    run "umount #{ target( '/proc' ) }" if FileTest.directory?( target( '/proc/self' ) )
    run "umount #{ target( '/dev/pts' ) } 2>&1" if FileTest.directory?( target( '/proc/self' ) )
  end


  ##############################################################################
  # Helpers
  ##############################################################################


  def ip_addresses
    ips = []
    SubProcess::Shell.open do | shell |
      shell.on_stdout do | line |
        ips << $1 if /inet addr:(\S+)\s+/=~ line
      end
      shell.exec "/sbin/ifconfig"
    end
    ips
  end


  def info message
    Lucie::Log.info message
    ( @messenger || $stdout ).puts message
  end


  def touch path
    Lucie::Utils.touch path, { :verbose => @verbose, :dry_run => @dry_run, :messenger => @messenger }
  end


  def mkdir_p path
    Lucie::Utils.mkdir_p path, { :verbose => @verbose, :dry_run => @dry_run, :messenger => @messenger }
  end


  def run command
    Lucie::Utils.run command, { :verbose => @verbose, :dry_run => @dry_run, :messenger => @messenger }
  end


  def write_file path, body
    Lucie::Utils.write_file path, body, { :verbose => @verbose, :dry_run => @dry_run, :messenger => @messenger }
  end


  def target path
    return File.expand_path( File.join( @target_directory, path ) )
  end


  def apt_option
    return { :root => @target_directory, :env => { 'http_proxy' => @http_proxy }, :verbose => @verbose, :dry_run => @dry_run }
  end


  def dpkg_divert *path
    path.each do | each |
      run "chroot #{ @target_directory } dpkg-divert --quiet --add --rename #{ each }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
