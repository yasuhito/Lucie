require "rubygems"

require "configuration"
require "facter"
require "first-stage/ssh"
require "first-stage/ssh-keys"
require "lucie/debug"
require "lucie/logger/html"
require "lucie/logger/installer"
require "lucie/server"
require "lucie/utils"
require "service"
require "status/installer"
require "sub-process"
require "tempfile"
require "ssh/home"


class FirstStage
  include Lucie::Debug
  include Lucie::Utils
  include SSH


  def initialize node, install_options, logger, debug_options = {}
    @node = node
    @install_options = install_options
    @suite = @install_options[ :suite ] || "stable"
    @logger = logger
    @debug_options = debug_options
  end


  def run
    update_status "Installation for '#{ @node.name }' started."
    system "ssh -i #{ private_key_path } #{ ::SSH::OPTIONS } root@#{ @node.name }" if @install_options[ :break ]
    all_steps.each do | each |
      __send__ each
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def all_steps
    [ :partition_disk,
      :install_base_system,
      :setup_fstab,
      :setup_sources_list,
      :mount_essentials,
      :install_kernel,
      :setup_grub,
      :setup_misc,
      :setup_ssh ]
  end


  def partition_disk
    update_status "Setting up hard disk partitions ..."
    scp @install_options[ :storage_conf ], "/tmp/storage.conf"
    ssh "setup-storage -X -f /tmp/storage.conf"
    ssh 'mount2dir /tmp/target /tmp/fstab'
  end


  def install_base_system
    update_status "Setting up Linux base system ..."
    scp @install_options[ :base_system ], "/tmp/target/base.tgz"
    ssh "tar -C /tmp/target -xzpf /tmp/target/base.tgz"
  end


  def install_kernel
    update_status "Installing a kernel package ..."
    scp "#{ Lucie::ROOT }/config/kernel-img.conf", "/tmp/target/etc/"
    apt_option = '-y --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
    linux_image_arch = case @install_options[ :arch ]
                       when "i386"
                         "486"
                       when "i686"
                         "686"
                       when "amd64"
                         "amd64"
                       else
                         raise "Invalid architecture: #{ @install_options[ :arch ] }"
                       end

    if @install_options[ :linux_image ] && FileTest.exists?( @install_options[ :linux_image ] )
      linux_image = "linux-image-#{ linux_image_arch }"
      ssh "chroot /tmp/target apt-get #{ apt_option } update"
      ssh "chroot /tmp/target apt-get #{ apt_option } install #{ linux_image }"
      custom_linux_image = @install_options[ :linux_image ]
      scp custom_linux_image, "/tmp/target/tmp"
      ssh "chroot /tmp/target dpkg -i /tmp/#{ File.basename custom_linux_image }"
    else
      linux_image = @install_options[ :linux_image ] || "linux-image-#{ linux_image_arch }"
      ssh "chroot /tmp/target apt-get #{ apt_option } update"
      ssh "chroot /tmp/target apt-get #{ apt_option } install #{ linux_image }"
    end
  end


  def setup_grub
    update_status "Setting up grub ..."
    ssh "setup_grub"
  end


  def setup_misc
    update_status "Generating misc configurations ..."
    setup_network
    setup_password
    run_hooks
  end


  def setup_ssh
    update_status "Setting up ssh ..."
    ssh "setup_ssh"
    SSHKeys.new( @node, @logger, @debug_options ).setup
  end


  # sub tasks ##################################################################


  def setup_fstab
    ssh 'mv /tmp/target/etc/fstab /tmp/target/etc/fstab.old'
    ssh 'cp -a /tmp/fstab /tmp/target/etc/fstab'
  end


  def setup_sources_list
    scp tempfile( sources_list ).path, "/tmp/target/etc/apt/sources.list"
  end


  def sources_list
    apt_line_package + apt_line_source
  end


  def apt_line_package
    apt_package_server = Lucie::Server.ip_address_for( [ @node ], @debug_options ) + ":" + Service::Approx::PORT.to_s
    <<-EOF
deb http://#{ apt_package_server }/#{ Service::Approx::DEBIAN_REPOSITORY } #{ @suite } main contrib non-free
deb http://#{ apt_package_server }/#{ Service::Approx::SECURITY_REPOSITORY } #{ @suite }/updates main contrib non-free
deb http://#{ apt_package_server }/#{ Service::Approx::VOLATILE_REPOSITORY } #{ @suite }/volatile main contrib non-free
EOF
  end


  def apt_line_source
    apt_line_package.gsub /^deb/, "deb-src"
  end


  def mount_essentials
    ssh 'mount -t proc proc /tmp/target/proc'
    ssh 'mount -t sysfs sysfs /tmp/target/sys'
    ssh '[ -f /etc/init.d/udev ] && mount --bind /dev/ /tmp/target/dev'
  end


  def setup_network
    ssh "setup_network #{ @node.name } #{ @node.mac_address } #{ @node.ip_address } #{ @node.netmask_address } #{ network_address } #{ broadcast_address } #{ Facter.value( 'domain' ) } #{ Facter.value( 'hostname' ) } #{ Facter.value( 'ipaddress' ) }"
  end


  def setup_password
    ssh "setup_password"
  end


  def run_hooks
    if hooks_exist?
      scp_r hooks_directory, "/tmp/target/tmp"
      scp "#{ Lucie::ROOT }/script/run-hooks", "/tmp/target/usr/sbin"
      ssh %{chroot /tmp/target run-hooks}
    end
  end


  # utils ######################################################################


  def update_status message
    info message
    @node.status.update message
  end


  def network_address
    Network.network_address @node.ip_address, @node.netmask_address
  end


  def broadcast_address
    Network.broadcast_address @node.ip_address, @node.netmask_address
  end


  def hooks_exist?
    @install_options[ :ldb_directory ] and FileTest.directory?( hooks_directory )
  end


  def hooks_directory
    File.join @install_options[ :ldb_directory ], "scripts/hooks"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
