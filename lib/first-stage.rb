require "rubygems"

require "configuration"
require "facter"
require "lucie/logger/html"
require "lucie/logger/installer"
require "lucie/server"
require "status/installer"
require "tempfile"


class FirstStage
  def initialize node, suite, linux_image, base_system, storage_conf, ldb_directory, logger, html_logger, options = {}, messenger = nil
    @node = node
    @suite = suite
    @linux_image = linux_image || "linux-image-686"
    @base_system = base_system
    @storage_conf = storage_conf
    @ldb_directory = ldb_directory
    @logger = logger
    @html_logger = html_logger
    @options = options
    @messenger = messenger
  end


  def run
    info "Installation for '#{ @node.name }' started."
    partition_disk
    install_base_system
    install_kernel
    setup_grub
    setup_misc
    setup_ssh
  end


  ##############################################################################
  private
  ##############################################################################


  def dry_run
    @options[ :dry_run ]
  end


  def verbose
    @options[ :verbose ]
  end


  # First stage steps ##########################################################


  def partition_disk
    @html_logger.new_step @node, "Setting up hard disk partitions ..."
    info "Setting up hard disk partitions ..."
    scp @storage_conf, "/tmp/storage.conf"
    ssh "setup-storage -X -f /tmp/storage.conf"
    ssh 'mount2dir /tmp/target /tmp/fstab'
  end


  def install_base_system
    @html_logger.new_step @node, 'Setting up Linux base system ...'
    info 'Setting up Linux base system ...'
    scp @base_system, "/tmp/target/base.tgz"
    ssh "tar -C /tmp/target -xzpf /tmp/target/base.tgz"
    ssh 'mv /tmp/target/etc/fstab /tmp/target/etc/fstab.old'
    ssh 'cp -a /tmp/fstab /tmp/target/etc/fstab'

    sources_list = Tempfile.new( "lucie" )
    sources_list.puts "deb http://#{ Lucie::Server.ip_address_for( [ @node ], @options ) }:9999/debian #{ @suite } main contrib non-free"
    sources_list.flush
    scp sources_list.path, '/tmp/target/etc/apt/sources.list'

    ssh 'mount -t proc proc /tmp/target/proc'
    ssh 'mount -t sysfs sysfs /tmp/target/sys'
    ssh '[ -f /etc/init.d/udev ] && mount --bind /dev/ /tmp/target/dev'
  end


  def install_kernel
    @html_logger.new_step @node, "Installing a kernel package ..."
    info "Installing a kernel package ..."
    scp "#{ Lucie::ROOT }/config/kernel-img.conf", "/tmp/target/etc/"
    apt_option = '-y --force-yes -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
    ssh "chroot /tmp/target apt-get #{ apt_option } update"
    ssh "chroot /tmp/target apt-get #{ apt_option } install #{ @linux_image }"
  end


  def setup_grub
    @html_logger.new_step @node, "Setting up grub ..."
    info "Setting up grub ..."
    ssh "setup_grub"
  end


  def setup_misc
    @html_logger.new_step @node, "Generating misc configurations ..."
    info "Generating misc configurations ..."
    ssh "setup_network #{ @node.name } #{ @node.mac_address } #{ @node.ip_address } #{ @node.netmask_address } #{ Network.network_address( @node.ip_address, @node.netmask_address ) } #{ Network.broadcast_address( @node.ip_address, @node.netmask_address ) } #{ Facter.value( 'domain' ) } #{ Facter.value( 'hostname' ) } #{ Facter.value( 'ipaddress' ) }"
    ssh "setup_password"
    if @ldb_directory and FileTest.directory?( File.join( @ldb_directory, "scripts/hooks" ) )
      scp_r File.join( @ldb_directory, "scripts/hooks" ), "/tmp/target/tmp"
      scp "#{ Lucie::ROOT }/script/run-hooks", "/tmp/target/usr/sbin"
      ssh %{chroot /tmp/target run-hooks}
    end
  end


  def setup_ssh
    @html_logger.new_step @node, "Setting up ssh ..."
    info "Setting up ssh ..."
    ssh "setup_ssh"
    [ "ssh_host_dsa_key", "ssh_host_rsa_key", "ssh_host_dsa_key.pub", "ssh_host_rsa_key.pub" ].each do | each |
      local_file = File.join( Configuration.log_directory, @node.name, each )
      if FileTest.exists? local_file
        scp local_file, "/tmp/target/etc/ssh"
        if /\.pub\Z/=~ each
          ssh "chmod 644 /tmp/target/etc/ssh/#{ each }"
        else
          ssh "chmod 600 /tmp/target/etc/ssh/#{ each }"
        end
      else
        from = File.join( "/tmp/target/etc/ssh", each )
        do_ssh "scp -i #{ SSH::PRIVATE_KEY } #{ SSH::OPTIONS } root@#{ @node.name }:#{ from } #{ local_file }"
      end
    end
  end


  # ssh/scp ####################################################################


  def ssh command
    do_ssh %{ssh -i #{ SSH::PRIVATE_KEY } #{ SSH::OPTIONS } root@#{ @node.name } "#{ command }"}
  end


  def scp from, to
    do_ssh %{scp -i #{ SSH::PRIVATE_KEY } #{ SSH::OPTIONS } #{ from } root@#{ @node.name }:#{ to }}
  end


  def scp_r from, to
    do_ssh %{scp -i #{ SSH::PRIVATE_KEY } #{ SSH::OPTIONS } -r #{ from } root@#{ @node.name }:#{ to }}
  end


  def do_ssh command
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        debug line
      end
      shell.on_stderr do | line |
        error line
      end
      shell.on_failure do
        raise %{Command "#{ command }" failed}
      end

      debug command if verbose
      shell.exec command unless dry_run
    end
  end


  # messages ###################################################################


  def stdout
    @messenger || $stdout
  end


  def stderr
    @messenger || $stderr
  end


  def info message
    stdout.puts message
    @logger.info message unless dry_run
  end


  def debug message
    stderr.puts message if verbose
    @logger.debug message unless dry_run
  end


  def error message
    stderr.puts message
    @logger.error message unless dry_run
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
