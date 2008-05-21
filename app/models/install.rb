require 'facter'


class Install
  attr_reader :label
  attr_reader :node


  # [FIXME] split into Install.latest, Install.new, etc ?
  def initialize node, label
    @node = node
    case label
    when :latest
      @label = labels.max
    when :new
      if labels.max
        @label = labels.max + 1
      else
        @label = 0
      end
      unless File.exist?( artifacts_directory )
        FileUtils.mkdir_p artifacts_directory
      end
    when Numeric, String
      @label = label.to_i
      unless File.exist?( artifacts_directory )
        FileUtils.mkdir_p artifacts_directory
      end
    else
      @label = 0
    end
    @status = InstallStatus.new( artifacts_directory )
  end


  def time
    @status.timestamp
  end


  def elapsed_time
    return @status.elapsed_time
  end


  def status
    return @status.to_s
  end


  def successful?
    return @status.succeeded?
  end


  def failed?
    return @status.failed?
  end


  def incomplete?
    return @status.incomplete?
  end


  def artifacts_directory
    return File.join( @node.path, "install-#{ label }" )
  end


  def artifact file_name
    return File.join( artifacts_directory, file_name )
  end


  def output
    begin
      log = ''
      File.open( artifact( 'install.log' ) ) do | file |
        log = file.read
      end
      return log
    rescue
      return ''
    end
  end


  def run
    begin
      time = Time.now
      @status.start!
      install
      @status.succeed!( ( Time.now - time ).ceil )
    rescue => e
      time_escaped = ( Time.now - ( time || Time.now ) ).ceil
      if e.is_a?( ConfigError )
        @status.fail! time_escaped, e.message
      else
        @status.fail! time_escaped
      end

      # rescued by install_node
      raise
    end
  end


  def labels
    return Dir[ @node.path + '/install-*' ].collect do | each |
      /install-(\d+)\Z/=~ each
      $1.to_i
    end
  end


  private


  def ssh_exec node_name, command
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        Lucie::Log.debug line
      end
      shell.on_stderr do | line |
        Lucie::Log.debug line
      end
      shell.on_failure do
        raise %{Command "#{ command }" failed}
      end

      shell.exec( %{ssh -o "StrictHostKeyChecking no" root@#{ node_name } "#{ command }"}, { :env => { 'LC_ALL' => 'C' } } )

      # Returns a instance of Popen3::Shell as a return value from
      # this block, in order to get child_status from the return value
      # of Kernel::ssh_exec.
      shell
    end
  end


  def install
    Lucie::Log.event "Installation for '#{ @node.name }' started."

    Lucie::Log.info 'Partitioning local harddisks'
    ssh_exec @node.name, 'setup_harddisks -d -X -l /tmp'

    Lucie::Log.info 'Mounting local harddisks'
    ssh_exec @node.name, 'mount2dir /tmp/target /tmp/fstab'

    Lucie::Log.info 'Extracting base system'
    ssh_exec @node.name, "tar -C /tmp/target -xzpf /var/tmp/#{ nfsroot_setting.distribution }_#{ nfsroot_setting.suite }_#{ nfsroot_setting.arch }.tgz"
    ssh_exec @node.name, 'mv /tmp/target/etc/fstab /tmp/target/etc/fstab.old'
    ssh_exec @node.name, 'cp -a /tmp/fstab /tmp/target/etc/fstab'

    ssh_exec @node.name, 'cp /etc/apt/sources.list.client /tmp/target/etc/apt/sources.list'
    ssh_exec @node.name, 'mount -t proc proc /tmp/target/proc'
    ssh_exec @node.name, 'mount -t sysfs sysfs /tmp/target/sys'
    ssh_exec @node.name, '[ -f /etc/init.d/udev ] && mount --bind /dev/ /tmp/target/dev'

    apt_option = '-y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
    ssh_exec @node.name, "chroot /tmp/target apt-get #{ apt_option } update"

    sh_exec "scp #{ RAILS_ROOT }/config/files/etc/kernel-img.conf root@#{ @node.name }:/tmp/target/etc/"
    ssh_exec @node.name, "install_packages --config-file=/etc/lucie/package.rb"

    Lucie::Log.info 'Setting up GRUB'
    ssh_exec @node.name, 'setup_grub'

    Lucie::Log.info 'Setting up network'
    ssh_exec @node.name, "setup_network #{ @node.name } #{ @node.mac_address } #{ @node.ip_address } #{ @node.netmask_address } #{ Network.network_address( @node.ip_address, @node.netmask_address ) } #{ Network.broadcast_address( @node.ip_address, @node.netmask_address ) } #{ @node.gateway_address } #{ Facter.value( 'domain' ) } #{ Facter.value( 'hostname' ) } #{ Facter.value( 'ipaddress' ) }"

    Lucie::Log.info 'Setting up puppet'
    ssh_exec @node.name, "setup_puppet #{ Facter.value( 'fqdn' ) }"

    Lucie::Log.info 'Setting up default password'
    ssh_exec @node.name, "setup_password"

    Lucie::Log.info 'Setting up SSH'
    ssh_exec @node.name, 'setup_ssh'

    ssh_exec @node.name, 'swapoff -a'

    LucieDaemon.server.disable_node [ @node.name ]

    ssh_exec @node.name, 'shutdown -r now'
  end


  # [HACK]
  def nfsroot_setting
    # [FIXME] hoaks assertions in Nfsroot#new
    ENV[ 'BUILD_LABEL' ] = 'DUMMY_LABEL'
    ENV[ 'INSTALLER_NAME' ] = @node.installer_name
    eval File.read( "#{ Installers.find( @node.installer_name ).path }/work/installer_config.rb" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
