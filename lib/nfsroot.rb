#
# Rake task definitions for creating a nfsroot.
#
# Nfsroot.configure defines following rake targets:
#
#  * installer:nfsroot: builds nfsroot.
#  * installer:clobber_nfsroot: clobbers nfsroot directory.
#  * installer:rebuild_nfsroot: clobbers and rebuilds nfsroot.
#
# plus, nfsroot base tasks (see NfsrootBase class).
#


require 'facter'
require 'lucie/log'
require 'nfsroot_base'
require 'popen3/apt'
require 'rake'
require 'rake/tasklib'
require 'ssh'


class Nfsroot < Rake::TaskLib
  attr_accessor :arch
  attr_accessor :distribution
  attr_accessor :extra_packages
  attr_accessor :http_proxy
  attr_accessor :kernel_package
  attr_accessor :mirror
  attr_accessor :root_password
  attr_accessor :sources_list
  attr_accessor :suite
  attr_accessor :target_directory


  def self.path installer_name
    last_build = Installer.new( installer_name ).builds.last
    File.join( Configuration.installers_directory, installer_name, "build-#{ last_build.label }", 'nfsroot' )
  end


  def initialize
    @name = :nfsroot

    @arch = 'i386'
    @http_proxy = nil
    @mirror = 'http://cdn.debian.or.jp/debian'
    @distribution = 'debian'
    @suite = 'etch'
    @kernel_package = 'linux-image-2.6.18-fai-kernels_1_i386.deb'
    @sources_list = 'deb http://192.168.1.1:9999/debian stable main contrib non-free'

    @extra_packages = nil
    @root_password = "h29SP9GgVbLHE"
    @target_directory = File.join( Configuration.installers_directory, ENV[ 'INSTALLER_NAME' ], "build-#{ ENV[ 'BUILD_LABEL' ] }", 'nfsroot' )
  end


  def self.configure &block
    nfsroot = self.new
    block.call nfsroot
    nfsroot.define_tasks
    return nfsroot
  end


  def verbose= verbose
    Lucie::Log.verbose = verbose
  end


  def define_tasks
    @nfsroot_base = NfsrootBase.configure do | task |
      task.arch = @arch
      task.mirror = @mirror
      task.distribution = @distribution
      task.suite = @suite
      task.http_proxy = @http_proxy
      task.include = [ 'grub', 'dhcp3-client', 'puppet' ]
    end

    directory @target_directory

    namespace 'installer' do
      desc "Build an nfsroot using #{ @nfsroot_base.tgz }."
      task @name do
        check_prerequisites
        STDOUT.puts 'Extracting installer base tarball. This may take a long time.'
        begin
          sh_exec "tar -C #{ @target_directory } -xzf #{ @nfsroot_base.tgz }"
          sh_exec "cp #{ @nfsroot_base.tgz } #{ target( '/var/tmp' ) }"

          hoaks_packages
          generate_etc_hosts
          upgrade_nfsroot
          add_packages_nfsroot
          copy_lucie_files
          finish_nfsroot
          install_kernel_nfsroot
          setup_ssh
          setup_dhcp
        ensure
          umount_dirs
        end
      end

      task @name => [ paste( 'installer:clobber_', @name ), @target_directory, 'installer:nfsroot_base' ]

      desc 'Force a rebuild of an nfsroot.'
      task paste( 'rebuild_', @name )

      desc "Remove #{ @target_directory }."
      task paste( 'clobber_', @name ) do
        if File.exist?( @target_directory )
          STDOUT.puts "#{ @target_directory } already exists. Removing #{ @target_directory }"

          # ignore errors when /dev/pts is not mounted.
          sh_exec "umount #{ target( '/dev/pts' ) } 2>&1" rescue nil
          sh_exec "umount #{ target( '/proc' ) }" rescue nil

          ( Dir.glob( target( '/dev/.??*' ) ) + Dir.glob( target( '/*' ) ) ).each do | each |
            sh_exec "rm -rf #{ each }"
          end

          # also remove files nfsroot/.? but not . and ..
          Popen3::Shell.open do | shell |
            shell.on_stdout do | line |
              sh_exec "rm -f #{ line }"
            end
            shell.exec( "find #{ @target_directory } -xdev -maxdepth 1 ! -type d'", { :env => { 'LC_ALL' => 'C' } } )
          end
        end
      end
    end
  end


  ################################################################################
  private
  ################################################################################


  def kernel_package_file
    return File.join( RAILS_ROOT, 'kernels', @kernel_package )
  end


  def target path
    return File.expand_path( File.join( @target_directory, path ) )
  end


  # hoaks some packages
  # liloconfig, dump and raidtool2 needs these files
  def hoaks_packages
    STDOUT.puts 'Modifying nfsroot to avoid errors caused by some packages.'

    sh_exec %{echo "#UNCONFIGURED FSTAB FOR BASE SYSTEM" > #{ target( 'etc/fstab' ) }}
    sh_exec "touch #{ target( 'etc/raidtab' ) }"

    sh_exec %{mkdir -p #{ target( "lib/modules/#{ get_kernel_version }" ) }}
    sh_exec %{touch #{ target( "lib/modules/#{ get_kernel_version }/modules.dep" ) }}
    sh_exec %{echo 'NTPSERVERS=""' > #{ target( 'etc/default/ntp-servers' ) }}

    unless FileTest.directory?( target( 'var/state' ) )
      sh_exec "mkdir #{ target( 'var/state' ) }"
    end
    unless FileTest.directory?( target( 'var/puppet' ) )
      sh_exec "mkdir #{ target( 'var/puppet' ) }"
    end
    File.open( target( 'etc/apt/sources.list' ), 'w' ) do | sources |
      sources.puts "deb #{ @mirror } #{ suite } main contrib non-free"
    end
    File.open( target( 'etc/apt/sources.list.client' ), 'w' ) do | sources |
      sources.puts @sources_list
    end
  end


  # [TODO] Support configuration option for adding arbitrary /etc/hosts entries.
  def generate_etc_hosts
    File.open( target( 'etc/hosts' ), 'w+' ) do | hosts |
      Popen3::Shell.open do | shell |
        shell.on_stdout do | line |
          if /inet addr:(\S+)\s+/=~ line
            hosts.print `getent hosts #{ $1 }`
          end
        end
        # [FIXME] use env_lc_all.
        shell.exec( 'ifconfig', { :env => { 'LC_ALL' => 'C' } } )
      end

      Nodes.load_all.each do | each |
        hosts.puts "#{ each.ip_address } #{ each.name }.#{ Facter.value( 'domain' ) } #{ each.name }"
      end
    end
  end


  def umount_dirs
    sh_exec "/usr/sbin/chroot #{ @target_directory } dpkg-divert --rename --remove /sbin/discover-modprobe"
    if FileTest.directory?( target( '/proc/self' ) )
      sh_exec "umount #{ target( '/proc' ) }"
    end
    if FileTest.directory?( target( '/proc/self' ) )
      sh_exec "umount #{ target( '/dev/pts' ) } 2>&1"
    end
  end


  def add_packages_nfsroot
    STDOUT.puts "Adding additional packages to nfsroot."
    packages = ( [ 'ruby', 'reiserfsprogs', 'discover', 'module-init-tools', 'ssh', 'udev', 'console-tools', 'psmisc', 'file' ] << @extra_packages ).flatten.uniq.compact
    STDOUT.puts "Adding packages to nfsroot: #{ packages.join( ', ' ) }"
    STDOUT.puts "NOTE: Error outputs generated by package installation scripts can be safely ignored."
    AptGet.update apt_option
    AptGet.apt( [ '-y', '--fix-missing', 'install' ] + packages, apt_option )
    AptGet.clean apt_option
  end


  def get_kernel_version
    if kernel_package.nil?
      raise "Option ``kernel_package'' is not set."
    end

    kernel_version = Popen3::Shell.open do | shell |
      kv = nil
      shell.on_stdout do | line |
        if /^ Package: \S+\-image\-(\S+)$/=~ line
          kv = $1
        end
      end
      shell.exec( "dpkg --info #{ kernel_package_file }", { :env => { 'LC_ALL' => 'C' } } )
      kv
    end

    if kernel_version
      return kernel_version
    end
    raise "Cannot determine kernel version."
  end


  def install_kernel_nfsroot
    STDOUT.puts "Installing kernel on nfsroot."
    Dir.glob( target( '/boot/*-' + get_kernel_version ) ).each do | each |
      sh_exec "rm -rf #{ each }"
    end
    sh_exec "rm -rf #{ target( '/lib/modules/' + get_kernel_version ) }"

    sh_exec %{echo "do_boot_enable=no" > #{ target( 'etc/kernel-img.conf' ) }}
    sh_exec %{dpkg -x #{ kernel_package_file } #{ @target_directory } }
    STDOUT.puts "Kernel #{ get_kernel_version } installed into the nfsroot."
    sh_exec %{chroot #{ @target_directory } depmod -qaF /boot/System.map-#{ get_kernel_version } #{ get_kernel_version }}
  end


  def upgrade_nfsroot
    # [TODO] generate target( 'etc/apt/apt.conf.d/10lucie' ) here.
    STDOUT.puts 'Upgrading nfsroot. This may take a long time.'
    if FileTest.file?( '/etc/resolv.conf' )
      sh_exec "cp -p /etc/resolv.conf #{ target( 'etc/resolv.conf-lucieserver' ) }"
      sh_exec "cp -p /etc/resolv.conf #{ target( 'etc/resolv.conf' ) }"
    end

    AptGet.update apt_option
    # [XXX] apt-get -fy install lucie-nfsroot
    sh_exec "mkdir -p #{ target( '/usr/lib/ruby/1.8' )}"
    sh_exec "cp -r #{ RAILS_ROOT }/lib/* #{ target( '/usr/lib/ruby/1.8' )}"
    AptGet.check apt_option

    sh_exec "rm -rf #{ target( 'etc/apm' ) }"
    sh_exec "mount -t proc /proc #{ target( 'proc' ) }"

    dpkg_divert '/sbin/start-stop-daemon', '/sbin/discover-modprobe'

    [ target( 'sbin/lucie-start-stop-daemon' ), target( 'sbin/start-stop-daemon' ) ].each do | each |
      File.open( each, 'w+' ) do | file |
        file.puts start_stop_daemon
      end
      sh_exec "chmod +x #{ each }"
    end

    AptGet.apt '-y dist-upgrade', apt_option
  end


  def apt_option
    return { :root => @target_directory, :env => { 'http_proxy' => @http_proxy } }
  end


  def setup_ssh
    SSH.setup do | ssh |
      ssh.target_directory = @target_directory
    end
  end


  def setup_dhcp
    pxebin = '/usr/lib/syslinux/pxelinux.0'
    pxecfg_dir = '/srv/tftp/lucie/pxelinux.cfg'
    tftp_kernel_target = "/srv/tftp/lucie/#{ ENV[ 'INSTALLER_NAME' ] }"

    STDOUT.puts 'Setting up DHCP and PXE environment.'
    unless FileTest.directory?( pxecfg_dir )
      sh_exec "mkdir -p #{ pxecfg_dir }"
    end
    sh_exec "cp -p #{ target( '/boot/vmlinuz-' + get_kernel_version ) } #{ tftp_kernel_target }"
    STDOUT.puts "Kernel #{ get_kernel_version } copied to #{ tftp_kernel_target }"
    sh_exec "cp #{ pxebin } /srv/tftp/lucie/"
    STDOUT.puts "DHCP environment prepared. If you want to use it, you have to enable the dhcpd and the tftp-hpa daemon."
  end


  def finish_nfsroot
    sh_exec "rm #{ target( '/etc/mtab' ) } #{ target( '/dev/MAKEDEV' ) }" rescue nil
    sh_exec "ln -s /proc/mounts #{ target( '/etc/mtab' ) }"
    unless FileTest.directory?( target( '/var/lib/discover' ) )
      sh_exec "mkdir #{ target( '/var/lib/discover' ) }"
    end
    unless FileTest.directory?( target( '/var/discover' ) )
      sh_exec "mkdir #{ target( '/var/discover' ) }"
    end
    sh_exec "mkdir #{ target( '/etc/sysconfig' ) } #{ target( '/tmp/etc' ) }"
    sh_exec "cp -p /etc/resolv.conf #{ target( '/tmp/etc' ) }"
    sh_exec "ln -sf /tmp/etc/resolv.conf #{ target( '/etc/resolv.conf' )}"
    sh_exec "cp #{ RAILS_ROOT }/script/rcS_lucie #{ target( '/etc/init.d/rcS' ) }"
    sh_exec "chmod +x #{ target( '/etc/init.d/rcS' ) }"

    sh_exec "cp #{ RAILS_ROOT }/script/setup_password #{ target( '/usr/sbin/setup_password' ) }"
    sh_exec "chmod +x #{ target( '/usr/sbin/setup_password' ) }"
    sh_exec "cp #{ RAILS_ROOT }/script/setup_harddisks #{ target( '/usr/sbin/setup_harddisks' ) }"
    sh_exec "chmod +x #{ target( '/usr/sbin/setup_harddisks' ) }"
    sh_exec "cp #{ RAILS_ROOT }/script/setup_grub #{ target( '/usr/sbin/setup_grub' ) }"
    sh_exec "chmod +x #{ target( '/usr/sbin/setup_grub' ) }"
    sh_exec "cp #{ RAILS_ROOT }/script/setup_network #{ target( '/usr/sbin/setup_network' ) }"
    sh_exec "chmod +x #{ target( '/usr/sbin/setup_network' ) }"
    sh_exec "cp #{ RAILS_ROOT }/script/setup_puppet #{ target( '/usr/sbin/setup_puppet' ) }"
    sh_exec "chmod +x #{ target( '/usr/sbin/setup_puppet' ) }"
    sh_exec "cp #{ RAILS_ROOT }/script/mount2dir #{ target( '/usr/sbin/mount2dir' ) }"
    sh_exec "chmod +x #{ target( '/usr/sbin/mount2dir' ) }"
    sh_exec "cp #{ RAILS_ROOT }/script/install_packages #{ target( '/usr/sbin/install_packages' ) }"
    sh_exec "chmod +x #{ target( '/usr/sbin/install_packages' ) }"
    sh_exec "cp #{ RAILS_ROOT }/script/fai-do-scripts #{ target( '/usr/sbin/fai-do-scripts' ) }"
    sh_exec "chmod +x #{ target( '/usr/sbin/fai-do-scripts' ) }"
    sh_exec "mkdir #{ target( '/etc/lucie' ) }"
    sh_exec "cp #{ target( '../../work/partition.rb' ) } #{ target( '/etc/lucie' ) }"
    sh_exec "cp #{ target( '../../work/package.rb' ) } #{ target( '/etc/lucie' ) }"
    sh_exec "cp -a #{ RAILS_ROOT }/config/scripts #{ target( '/etc/lucie' ) }"

    if FileTest.directory?( target( '/var/yp' ) )
      sh_exec "ln -s /tmp/binding #{ target( '/var/yp/binding' ) }"
    end
    sh_exec %{echo "iface lo inet loopback" > #{ target( '/etc/network/interfaces' ) }}
    sh_exec %{echo "*.* /tmp/syslog.log" > #{ target( '/etc/syslog.conf' ) }}
  end


  def copy_lucie_files
    sh_exec %{echo "root:#{ @root_password }" | chroot #{ @target_directory } chpasswd --encrypted}
    sh_exec %{chroot #{ @target_directory } shadowconfig on}
  end


  def check_prerequisites
    [ { :file => '/usr/lib/syslinux/pxelinux.0', :message => 'syslinux not installed' },
      { :file => '/usr/sbin/debootstrap', :message => 'debootstrap not installed' },
      { :file => kernel_package_file, :message => "kernel_package (= '#{ kernel_package_file }') not found" } ].each do | each |
      unless FileTest.exists?( each[ :file ] )
        raise each[ :message ]
      end
    end
  end


  def dpkg_divert *path
    path.each do | each |
      sh_exec "chroot #{ @target_directory } dpkg-divert --quiet --add --rename #{ each }"
    end
  end


  def start_stop_daemon
    return( <<-START_STOP_DAEMON )
#! /bin/sh

# $Id: nfsroot-task.rb 29 2007-05-11 06:48:21Z yasuhito $
#*********************************************************************
#
# start-stop-daemon -- a version which never starts daemons
#
# This script is part of FAI (Fully Automatic Installation)
# (c) 2000-2006 by Thomas Lange, lange@informatik.uni-koeln.de
# Universitaet zu Koeln
#
#*********************************************************************
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# A copy of the GNU General Public License is available as
# `/usr/share/common-licences/GPL' in the Debian GNU/Linux distribution
# or on the World Wide Web at http://www.gnu.org/copyleft/gpl.html.  You
# can also obtain it by writing to the Free Software Foundation, Inc.,
# 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#*********************************************************************

while [ $# -gt 0 ]; do
    case $1 in
        -x|--exec) shift; prog="for $1" ;;
        -o|--oknodo) oknodo=1 ;;
        -S|--start) start=1 ;;
        -K|--stop) stop=1 ;;
        esac
    shift
done

case $prog in
    *udevd) /sbin/start-stop-daemon.distrib --start --quiet --exec /sbin/udevd -- --daemon
           ;;
        *) echo ""
           echo "Warning: Dummy start-stop-daemon called $prog. Doing nothing."
           ;;
esac

[ -n "$stop" -a -z "$oknodo" ] && exit 1

exit 0
START_STOP_DAEMON
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
