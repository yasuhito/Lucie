#
# $Id: nfsroot-task.rb 29 2007-05-11 06:48:21Z yasuhito $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 29 $
# License::  GPL2


require 'lucie'
require 'nfsroot_base'
require 'popen3/apt'
require 'rake'
require 'rake/tasklib'


class Nfsroot < Rake::TaskLib
  include Lucie


  attr_accessor :distribution
  attr_accessor :extra_packages
  attr_accessor :http_proxy
  attr_accessor :kernel_package
  attr_accessor :logging_level
  attr_accessor :mirror
  attr_accessor :root_password
  attr_accessor :sources_list
  attr_accessor :ssh_identity
  attr_accessor :suite


  def initialize
    @name = :nfsroot

    @logging_level = :debug
    # XXX logging_level is not configurable
    Lucie.logging_level = @logging_level

    @http_proxy = nil
    @mirror = 'http://cdn.debian.or.jp/debian'
    @distribution = 'debian'
    @suite = 'etch'
    @kernel_package = 'linux-image-2.6.18-fai-kernels_1_i386.deb'
    @sources_list = 'deb http://192.168.1.1:9999/debian main contrib non-free'

    @extra_packages = nil
    @root_password = "h29SP9GgVbLHE"
    @target_directory = './nfsroot'

    Popen3::Shell.logger = Lucie
  end


  def self.configure &block
    nfsroot = self.new
    block.call nfsroot
    nfsroot.define_tasks
    return nfsroot
  end


  def define_tasks
    @nfsroot_base = NfsrootBase.configure do | task |
      task.mirror = @mirror
      task.distribution = @distribution
      task.suite = @suite
      task.http_proxy = @http_proxy
    end

    directory @target_directory

    namespace 'installer' do
      desc "Build an nfsroot using #{ @nfsroot_base.tgz }."
      task @name do
        check_prerequisites
        Lucie::Log.info 'Extracting installer base tarball. This may take a long time.'
        begin
          sh_exec 'tar', '-C', @target_directory, '-xzf', @nfsroot_base.tgz
          sh_exec 'cp', @nfsroot_base.tgz, target( '/var/tmp' )

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
      task paste( 'update_', @name )

      desc "Remove #{ @target_directory }."
      task paste( 'clobber_', @name ) do
        if File.exist?( @target_directory )
          Lucie::Log.info "#{ @target_directory } already exists. Removing #{ @target_directory }"

          sh_exec "umount #{ target( '/dev/pts' ) } 2>&1"
          
          ( Dir.glob( target( '/dev/.??*' ) ) + Dir.glob( target( '/*' ) ) ).each do | each |
            sh_exec 'rm', '-rf', each
          end
          
          # also remove files nfsroot/.? but not . and ..
          Popen3::Shell.open do | shell |
            shell.on_stdout do | line |
              sh_exec 'rm', '-f', line
            end
            shell.exec( { 'LC_ALL' => 'C' }, 'find', @target_directory, '-xdev', '-maxdepth', '1', '!', '-type', 'd' )
          end
        end
      end
    end
  end


  private


  def kernel_package_file
    return File.join( '../../kernels', @kernel_package )
  end


  def target path
    return File.join( @target_directory, path ).gsub( /\/+/, '/' )
  end


  # hoaks some packages
  # liloconfig, dump and raidtool2 needs these files
  def hoaks_packages
    Lucie::Log.info 'Modifying nfsroot to avoid errors caused by some packages.'

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
        shell.exec( { 'LC_ALL' => 'C' }, 'ifconfig' )
      end
    end
  end


  def umount_dirs
    sh_exec "chroot #{ @target_directory } dpkg-divert --rename --remove /sbin/discover-modprobe"
    if FileTest.directory?( target( '/proc/self' ) )
      sh_exec "umount #{ target( '/proc' ) }"
    end
    if FileTest.directory?( target( '/proc/self' ) )
      sh_exec "umount #{ target( '/dev/pts' ) } 2>&1"
    end
  end


  def add_packages_nfsroot
    Lucie::Log.info "Adding additional packages to nfsroot."
    packages = ( [ 'ruby', 'reiserfsprogs', 'discover', 'module-init-tools', 'ssh', 'udev', 'console-tools', 'psmisc', 'puppet', 'file' ] << @extra_packages ).flatten.uniq.compact
    Lucie::Log.info "Adding packages to nfsroot: #{ packages.join( ', ' ) }"
    Lucie::Log.info "NOTE: Error outputs generated by package installation scripts can be safely ignored."
    AptGet.update apt_option
    AptGet.apt( [ '-y', '--fix-missing', 'install' ] + packages, apt_option )
    AptGet.clean apt_option
  end


  def get_kernel_version
    if @kernel_package.nil?
      raise "Option ``kernel_package'' is not set."
    end

    kernel_version = Popen3::Shell.open do | shell |
      kv = nil
      shell.on_stdout do | line |
        if /^ Package: \S+\-image\-(\S+)$/=~ line
          kv = $1
        end
      end
      shell.logging_off
      shell.exec( { 'LC_ALL' => 'C' }, 'dpkg', '--info', kernel_package_file )
      shell.logging_on
      kv
    end

    if kernel_version
      return kernel_version
    end
    raise "Cannot determine kernel version."
  end


  def install_kernel_nfsroot
    Lucie::Log.info "Installing kernel on nfsroot."
    Dir.glob( target( '/boot/*-' + get_kernel_version ) ).each do | each |
      sh_exec "rm -rf #{ each }"
    end
    sh_exec "rm -rf #{ target( '/lib/modules/' + get_kernel_version ) }"

    sh_exec %{echo "do_boot_enable=no" > #{ target( 'etc/kernel-img.conf' ) }}
    sh_exec %{dpkg -x #{ kernel_package_file } #{ @target_directory } }
    Lucie::Log.info "Kernel #{ get_kernel_version } installed into the nfsroot."
    sh_exec %{chroot #{ @target_directory } depmod -qaF /boot/System.map-#{ get_kernel_version } #{ get_kernel_version }}
  end


  def upgrade_nfsroot
    # [TODO] generate target( 'etc/apt/apt.conf.d/10lucie' ) here.
    Lucie::Log.info "Upgrading nfsroot. This may take a long time."
    if FileTest.file?( '/etc/resolv.conf' )
      sh_exec "cp -p /etc/resolv.conf #{ target( 'etc/resolv.conf-lucieserver' ) }"
      sh_exec "cp -p /etc/resolv.conf #{ target( 'etc/resolv.conf' ) }"
    end

    AptGet.update apt_option
    # [XXX] apt-get -fy install lucie-nfsroot
    sh_exec "mkdir -p #{ target( '/usr/lib/ruby/1.8' )}"
    sh_exec "cp -r ../../lib/* #{ target( '/usr/lib/ruby/1.8' )}"
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

    AptGet.apt [ '-y', 'dist-upgrade' ], apt_option
  end


  # [XXX] Eliminate hard-coded proxy URI and logger.
  def apt_option
    return { :root => @target_directory, :env => { 'http_proxy' => @http_proxy }, :logger => Lucie }
  end


  def setup_ssh
    unless FileTest.exists?( target( '/usr/bin/ssh' ) )
      return
    end
    sh_exec "mkdir -p -m 700 #{ target( '/root/.ssh' ) }"

    # enable root login
    sh_exec "perl -pi -e 's/PermitRootLogin no/PermitRootLogin yes/' #{ target( 'etc/ssh/sshd_config' ) }"
    if @ssh_identity && FileTest.exists?( @ssh_identity )
      sh_exec "cp #{ @ssh_identity } #{ target( 'root/.ssh/authorized_keys' ) }"
      sh_exec "chmod 0644 #{ target( 'root/.ssh/authorized_keys' ) }"
      Lucie::Log.info "You can log into install clients without password using #{ @ssh_identity }"
    end
  end


  def setup_dhcp
    pxebin = '/usr/lib/syslinux/pxelinux.0'
    pxecfg_dir = '/srv/tftp/lucie/pxelinux.cfg'
    tftp_kernel_target = '/srv/tftp/lucie/vmlinuz-install'

    Lucie::Log.info 'Setting up DHCP and PXE environment.'
    sh_exec "cp -p #{ target( '/boot/vmlinuz-' + get_kernel_version ) } #{ tftp_kernel_target }"
    Lucie::Log.info "Kernel #{ get_kernel_version } copied to #{ tftp_kernel_target }"
    sh_exec "cp #{ pxebin } /srv/tftp/lucie/"
    unless FileTest.directory?( pxecfg_dir )
      sh_exec "mkdir -p #{ pxecfg_dir }"
    end
    Lucie::Log.info "DHCP environment prepared. If you want to use it, you have to enable the dhcpd and the tftp-hpa daemon."
  end


  def finish_nfsroot
    sh_exec "rm #{ target( '/etc/mtab' ) } #{ target( '/dev/MAKEDEV' ) }"
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
    sh_exec "cp ../../bin/rcS_lucie #{ target( '/etc/init.d/rcS' ) }"
    sh_exec "chmod +x #{ target( '/etc/init.d/rcS' ) }"

    sh_exec "cp ../../bin/setup_harddisks #{ target( '/usr/sbin/setup_harddisks' ) }"
    sh_exec "chmod +x #{ target( '/usr/sbin/setup_harddisks' ) }"
    sh_exec "cp ../../bin/mount2dir #{ target( '/usr/sbin/mount2dir' ) }"
    sh_exec "chmod +x #{ target( '/usr/sbin/mount2dir' ) }"
    sh_exec "cp ../../bin/install_packages #{ target( '/usr/sbin/install_packages' ) }"
    sh_exec "chmod +x #{ target( '/usr/sbin/install_packages' ) }"
    sh_exec "cp ../../bin/fai-do-scripts #{ target( '/usr/sbin/fai-do-scripts' ) }"
    sh_exec "chmod +x #{ target( '/usr/sbin/fai-do-scripts' ) }"
    sh_exec "mkdir #{ target( '/etc/lucie' ) }"
    sh_exec "cp ./work/partition.rb #{ target( '/etc/lucie' ) }"
    sh_exec "cp ./work/package.rb #{ target( '/etc/lucie' ) }"
    sh_exec "cp -a ../../config/scripts #{ target( '/etc/lucie' ) }"

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
      { :file => kernel_package_file, :message => "kernel_package (= '#{ @kernel_package}') not found" } ].each do | each |
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
### coding: utf-8
### indent-tabs-mode: nil
### End:
