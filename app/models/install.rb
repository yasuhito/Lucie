class Install
  include CommandLine


  attr_reader :label
  attr_reader :node


  def initialize node, label
    @node = node
    case label
    when :latest
      @label = labels.max
    when :new
      @label = labels.max + 1
    else
      @label = label
    end
    unless File.exist?( artifacts_directory )
      FileUtils.mkdir_p artifacts_directory
    end
    @status = InstallStatus.new( artifacts_directory )
    @install_log = STDERR
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
      return File.read( artifact( 'install.log' ) )
    rescue
      return ''
    end
  end


  def run
    begin
      @install_log = File.open( artifact( 'install.log' ), 'a' )

      time = Time.now
      @status.start!
      install
      @status.succeed!( ( Time.now - time ).ceil )
    rescue => e
      @install_log << e.message

      Lucie::Log.verbose? ? Lucie::Log.debug( e ) : Lucie::Log.info( e.message )
      time_escaped = ( Time.now - ( time || Time.now ) ).ceil

      if e.is_a?( ConfigError )
        @status.fail! time_escaped, e.message
      else
        @status.fail! time_escaped
      end
    end
  end


  def labels
    return Dir[ @node.path + '/install-*' ].collect do | each |
      /install-(\d+)\Z/=~ each
      $1.to_i
    end
  end


  private


  def ssh_exec node_name, *command
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        @install_log.puts line
      end

      shell.on_stderr do | line |
        @install_log.puts line
      end

      shell.on_failure do
        raise %{Command "#{ command.join( ' ' ) }" failed}
      end

      @install_log.puts "[root@#{ INSTALLER_OPTIONS[ :node_name ] }] " + command.join( ' ' )
      shell.exec( { 'LC_ALL' => 'C' }, *( [ 'ssh', "root@#{ INSTALLER_OPTIONS[ :node_name ] }" ] + command ) )

      # Returns a instance of Popen3::Shell as a return value from
      # this block, in order to get child_status from the return value
      # of Kernel::ssh_exec.
      shell
    end
  end


  def install
    Lucie::Log.event "Installation for '#{ INSTALLER_OPTIONS[ :node_name ] }' started."

    Lucie::Log.info 'Partitioning local harddisks'
    ssh_exec @node.name, 'setup_harddisks -d -X -l /tmp'

    Lucie::Log.info 'Mounting local harddisks'
    ssh_exec @node.name, 'mount2dir /tmp/target /tmp/fstab'

    Lucie::Log.info 'Extracting base system'
    ssh_exec @node.name, 'zcat /var/tmp/*.tgz | tar -C /tmp/target -xpf -'
    ssh_exec @node.name, 'mv /tmp/target/etc/fstab /tmp/target/etc/fstab.old'
    ssh_exec @node.name, 'cp -a /tmp/fstab /tmp/target/etc/fstab'

    ssh_exec @node.name, 'cp /etc/apt/sources.list.client /tmp/target/etc/apt/sources.list'
    ssh_exec @node.name, 'mount -t proc proc /tmp/target/proc'
    ssh_exec @node.name, 'mount -t sysfs sysfs /tmp/target/sys'
    ssh_exec @node.name, '[ -f /etc/init.d/udev ] && mount --bind /dev/ /tmp/target/dev'

    apt_option = '-y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"'
    ssh_exec @node.name, "chroot /tmp/target apt-get #{ apt_option } update"

    sh_exec "scp #{ RAILS_ROOT }/config/files/etc/kernel-img.conf root@#{ @node.name }:/tmp/target/etc/"
    ssh_exec @node.name, 'install_packages --config-file=/etc/lucie/package.rb'

    Lucie::Log.info 'Setting up GRUB'
    ssh_exec @node.name, 'setup_grub'

    Lucie::Log.info 'Setting up network'
    ssh_exec @node.name, "setup_network #{ @node.name }"
    sh_exec "scp /etc/hosts root@#{ @node.name }:/tmp/target/etc/"

    Lucie::Log.info 'Setting up puppet'
    ssh_exec @node.name, "setup_puppet #{ `hostname -f`.chomp }"

    ssh_exec @node.name, 'swapoff -a'
  end
end
