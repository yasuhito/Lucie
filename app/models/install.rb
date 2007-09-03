class Install
  include CommandLine


  attr_reader :label
  attr_reader :node


  def initialize node, label
    @node = node
    @label = label
    unless File.exist?( artifacts_directory )
      FileUtils.mkdir_p artifacts_directory
    end
    @status = InstallStatus.new( artifacts_directory )
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
    return( @artifacts_dir ||= File.join( @node.path, "install-#{ label }" ) )
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


  def rake
    # [XXX] returns a task to install a node.
    return %{ls}
  end


  def command
    return( node.install_command or rake )
  end


  def run
    begin
      install_log = artifact( 'install.log' )

      # install_command must be set before doing chdir, because there may
      # be some relative paths
      install_command = self.command
      time = Time.now
      @status.start!

      in_node_directory do
        execute install_command, :stdout => install_log, :stderr => install_log, :escape_quotes => false
      end
      @status.succeed!( ( Time.now - time ).ceil )
    rescue => e
      File.open( install_log, 'a' ) do | file |
        file << e.message
      end

      Lucie::Log.verbose? ? Lucie::Log.debug( e ) : Lucie::Log.info( e.message )
      time_escaped = ( Time.now - ( time || Time.now ) ).ceil

      if e.is_a?( ConfigError )
        @status.fail! time_escaped, e.message
      else
        @status.fail! time_escaped
      end
    end
  end


  def in_node_directory &block
    Dir.chdir( node.path ) do
      block.call
    end
  end
end
