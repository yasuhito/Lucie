#
# $Id$
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License::  GPL2


require 'lucie'
require 'lucie/installer-base-task'
require 'popen3/apt'
require 'rake'
require 'rake/tasklib'


module Rake
  class NfsrootTask < TaskLib
    include Lucie


    NFSROOT_DIRECTORY = '/var/lib/lucie/nfsroot/'.freeze
    CONFIGURATION_NAME_STAMP = '/etc/lucie/.configuration_name'.freeze
    INSTALLER_NAME_STAMP = '/etc/lucie/.installer_name'.freeze
    LMP_SERVER = 'lucie-dev.titech.hpcc.jp'


    attr_accessor :distribution
    attr_accessor :extra_packages
    attr_accessor :http_proxy
    attr_accessor :kernel_package
    attr_accessor :logging_level
    attr_accessor :mirror
    attr_accessor :name
    attr_accessor :root_password
    attr_accessor :sources_list
    attr_accessor :ssh_identity
    attr_accessor :suite
    attr_accessor :target_directory


    def self.load_file file # :nodoc:
      @@file = file
    end


    def self.load_aptget aptget # :nodoc:
      @@aptget = aptget
    end


    def self.load_shell shell_class # :nodoc:
      @@shell = shell_class
      Kernel.load_shell shell_class
    end


    def self.reset # :nodoc:
      load_file File
      load_aptget AptGet
      load_shell Popen3::Shell
    end


    reset


    def initialize name = :nfsroot # :yield: self
      @extra_packages = nil
      @mirror = 'http://www.debian.or.jp/debian'
      @name = name
      @root_password = "h29SP9GgVbLHE"
      @suite = 'stable'
      @distribution = 'debian'
      @target_directory = NFSROOT_DIRECTORY
      @logging_level = :info
      @http_proxy = nil
      yield self if block_given?

      @@shell.logger = Lucie
      Lucie.logging_level = @logging_level

      define_tasks
    end


    private


    def target path
      return File.join( @target_directory, path ).gsub( /\/+/, '/' )
    end


    # hoaks some packages
    # liloconfig, dump and raidtool2 needs these files
    def hoaks_packages
      info 'Modifying nfsroot to avoid errors caused by some packages.'

      sh_exec %{echo "#UNCONFIGURED FSTAB FOR BASE SYSTEM" > #{ target( 'etc/fstab' ) }}
      sh_exec "touch #{ target( 'etc/raidtab' ) }"

      sh_exec %{mkdir -p #{ target( "lib/modules/#{ get_kernel_version }" ) }}
      sh_exec %{touch #{ target( "lib/modules/#{ get_kernel_version }/modules.dep" ) }}
      sh_exec %{echo 'NTPSERVERS=""' > #{ target( 'etc/default/ntp-servers' ) }}

      unless FileTest.directory?( target( 'var/state' ) )
        sh_exec "mkdir #{ target( 'var/state' ) }"
      end
      @@file.open( target( 'etc/apt/sources.list' ), 'w' ) do | sources |
        sources.puts "deb #{ @mirror } #{ suite } main contrib non-free"
      end
      @@file.open( target( 'etc/apt/sources.list.client' ), 'w' ) do | sources |
        sources.puts @sources_list
      end
    end


    # [TODO] Support configuration option for adding arbitrary /etc/hosts entries.
    def generate_etc_hosts
      @@file.open( target( 'etc/hosts' ), 'w+' ) do | hosts |
        @@shell.open do | shell |
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
        sh_exec "umount #{ target( '/dev/pts' ) }"
      end
    end


    def add_packages_nfsroot
      info "Adding additional packages to nfsroot."
      packages = ( [ 'ruby', 'reiserfsprogs', 'discover', 'module-init-tools', 'ssh', 'udev', 'console-tools' ] << @extra_packages ).flatten.uniq.compact
      info "Adding packages to nfsroot: #{ packages.join( ', ' ) }"
      @@aptget.update apt_option
      @@aptget.apt( [ '-y', '--fix-missing', 'install' ] + packages, apt_option )
      @@aptget.clean apt_option
    end


    def get_kernel_version
      if @kernel_package.nil?
        raise "Option ``kernel_package'' is not set."
      end

      kernel_version = @@shell.open do | shell |
        kv = nil
        shell.on_stdout do | line |
          if /^ Package: \S+\-image\-(\S+)$/=~ line
            kv = $1
          end
        end
        shell.logging_off
        shell.exec( { 'LC_ALL' => 'C' }, 'dpkg', '--info', @kernel_package )
        shell.logging_on
        kv
      end

      if kernel_version
        return kernel_version
      end
      raise "Cannot determine kernel version."
    end


    def install_kernel_nfsroot
      info "Installing kernel on nfsroot."
      Dir.glob( target( '/boot/*-' + get_kernel_version ) ).each do | each |
        sh_exec "rm -rf #{ each }"
      end
      sh_exec "rm -rf #{ target( '/lib/modules/' + get_kernel_version ) }"

      sh_exec %{echo "do_boot_enable=no" > #{ target( 'etc/kernel-img.conf' ) }}
      sh_exec %{dpkg -x #{ @kernel_package } #{ @target_directory } }
      info "Kernel #{ get_kernel_version } installed into the nfsroot."
      sh_exec %{chroot #{ @target_directory } depmod -qaF /boot/System.map-#{ get_kernel_version } #{ get_kernel_version }}
    end


    def upgrade_nfsroot
      # [TODO] generate target( 'etc/apt/apt.conf.d/10lucie' ) here.
      info "Upgrading nfsroot. This may take a long time."
      if FileTest.file?( '/etc/resolv.conf' )
        sh_exec "cp -p /etc/resolv.conf #{ target( 'etc/resolv.conf-lucieserver' ) }"
        sh_exec "cp -p /etc/resolv.conf #{ target( 'etc/resolv.conf' ) }"
      end

      @@aptget.update apt_option
      # [XXX] apt-get -fy install lucie-nfsroot
      sh_exec "mkdir -p #{ target( '/usr/lib/ruby/1.8' )}"
      sh_exec "cp -r lib/* #{ target( '/usr/lib/ruby/1.8' )}"
      @@aptget.check apt_option

      sh_exec "rm -rf #{ target( 'etc/apm' ) }"
      sh_exec "mount -t proc /proc #{ target( 'proc' ) }"

      dpkg_divert '/sbin/start-stop-daemon', '/sbin/discover-modprobe'

      [ target( 'sbin/lucie-start-stop-daemon' ), target( 'sbin/start-stop-daemon' ) ].each do | each |
        @@file.open( each, 'w+' ) do | file |
          file.puts start_stop_daemon
        end
        sh_exec "chmod +x #{ each }"
      end

      @@aptget.apt [ '-y', 'dist-upgrade' ], apt_option
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
        info "You can log into install clients without password using #{ @ssh_identity }"
      end
    end


    def setup_dhcp
      pxebin = '/usr/lib/syslinux/pxelinux.0'
      pxecfg_dir = '/srv/tftp/lucie/pxelinux.cfg'
      tftp_kernel_target = '/srv/tftp/lucie/vmlinuz-install'

      info 'Setting up DHCP and PXE environment.'
      sh_exec "cp -p #{ target( '/boot/vmlinuz-' + get_kernel_version ) } #{ tftp_kernel_target }"
      info "Kernel #{ get_kernel_version } copied to #{ tftp_kernel_target }"
      sh_exec "cp #{ pxebin } /srv/tftp/lucie/"
      unless FileTest.directory?( pxecfg_dir )
        sh_exec "mkdir -p #{ pxecfg_dir }"
      end
      info "DHCP environment prepared. If you want to use it, you have to enable the dhcpd and the tftp-hpa daemon."
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
      # sh_exec "ln -s /usr/sbin/fai #{ target( '/etc/init.d/rcS' ) }"
      sh_exec "cp bin/rcS_lucie #{ target( '/etc/init.d/rcS' ) }"
      sh_exec "chmod +x #{ target( '/etc/init.d/rcS' ) }"

      sh_exec "cp ../../bin/hwdetect #{ target( '/usr/sbin/hwdetect' ) }"
      sh_exec "chmod +x #{ target( '/usr/sbin/hwdetect' ) }"
      sh_exec "cp bin/setup_harddisks #{ target( '/usr/sbin/setup_harddisks' ) }"
      sh_exec "chmod +x #{ target( '/usr/sbin/setup_harddisks' ) }"
      sh_exec "cp bin/mount2dir #{ target( '/usr/sbin/mount2dir' ) }"
      sh_exec "chmod +x #{ target( '/usr/sbin/mount2dir' ) }"
      sh_exec "cp bin/install_packages #{ target( '/usr/sbin/install_packages' ) }"
      sh_exec "chmod +x #{ target( '/usr/sbin/install_packages' ) }"
      sh_exec "mkdir #{ target( '/etc/lucie' ) }"
      sh_exec "cp config/partition.rb #{ target( '/etc/lucie' ) }"

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
        { :file => @kernel_package, :message => "kernel_package (= '#{ @kernel_package}') not found" } ].each do | each |
        unless FileTest.exists?( each[ :file ] )
          raise each[ :message ]
        end
      end
    end


    def define_tasks
      @installer_base = Rake::InstallerBaseTask.new do | task |
        task.mirror = @mirror
        task.distribution = @distribution
        task.suite = @suite
        # [FIXME] get proxy URI from config file, not hard coded.
        task.http_proxy = @http_proxy
      end

      desc "Build an nfsroot using #{ @installer_base.tgz }."
      task @name do
        check_prerequisites
        info 'Extracting installer base tarball. This may take a long time.'
        begin
          sh_exec 'tar', '-C', @target_directory, '-xzf', @installer_base.tgz
          sh_exec 'cp', @installer_base.tgz, target( '/var/tmp' )

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

      desc 'Force a rebuild of an nfsroot.'
      task paste( 're', @name )

      desc "Remove #{ @target_directory }."
      task paste( 'clobber_', @name ) do
        info "#{ @target_directory } already exists. Removing #{ @target_directory }"

        sh_exec 'umount', target( '/dev/pts' )

        ( Dir.glob( target( '/dev/.??*' ) ) + Dir.glob( target( '/*' ) ) ).each do | each |
          sh_exec 'rm', '-rf', each
        end

        # also remove files nfsroot/.? but not . and ..
        @@shell.open do | shell |
          shell.on_stdout do | line |
            sh_exec 'rm', '-f', line
          end
          shell.exec( { 'LC_ALL' => 'C' }, 'find', @target_directory, '-xdev', '-maxdepth', '1', '!', '-type', 'd' )
        end
      end

      directory @target_directory

      # define task dependencies.
      task @name => [ paste( 'clobber_', @name ), @target_directory, :installer_base ]
    end


    def dpkg_divert *path
      path.each do | each |
        sh_exec "chroot #{ @target_directory } dpkg-divert --quiet --add --rename #{ each }"
      end
    end


    def start_stop_daemon
      return( <<-START_STOP_DAEMON )
#! /bin/sh

# $Id$
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
end


### Local variables:
### mode: Ruby
### coding: euc-jp-unix
### indent-tabs-mode: nil
### End:
