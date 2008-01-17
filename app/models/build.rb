class Build
  IGNORE_ARTIFACTS = /\A(\..*|build_status\..+|build.log|changeset.log|lucie_config.rb|plugin_errors.log)\Z/


  attr_reader :installer
  attr_reader :label


  def initialize installer, label
    @installer = installer
    @label = label
    unless File.exist?( artifacts_directory )
      FileUtils.mkdir_p artifacts_directory
    end
    @status = BuildStatus.new( artifacts_directory )
  end


  def time
    @status.timestamp
  end


  def plugin_errors
    begin
      log = ''
      File.open( artifact( 'plugin_errors.log' ) ) do | file |
        log = file.read
      end
      return log
    rescue
      return ''
    end
  end


  def brief_error
    if File.size( @status.status_file ) > 0
      return 'config error'
    end
    unless plugin_errors.empty?
      return 'plugin error'
    end
    return nil
  end


  def url
    dashboard_url = Configuration.dashboard_url
    if dashboard_url.nil? || dashboard_url.empty?
      raise 'Configuration.dashboard_url is not specified'
    end
    # [???] How ActionController::Routing::Routes determines this routing?
    return( dashboard_url + ActionController::Routing::Routes.generate( :controller => 'builds', :action => 'show', :installer => installer, :build => to_param ) )
  end


  def changeset
    begin
      log = ''
      File.open( artifact( 'changeset.log' ) ) do | file |
        log = file.read
      end
      return log
    rescue
      return ''
    end
  end


  def failed?
    return @status.failed?
  end


  def successful?
    return @status.succeeded?
  end


  def to_param
    return self.label
  end


  def rake
    verbose_option = Lucie::Log.verbose? ? " << '--trace'" : ''
    rakefile = "#{ @installer.path }/work/installer_config.rb"

    return %{ruby -I#{ File.expand_path( RAILS_ROOT ) }/lib -e "require '#{ File.expand_path( RAILS_ROOT ) + '/config/environment' }'; require 'rubygems' rescue nil; require 'rake'; require 'nfsroot'; load '#{ File.expand_path( RAILS_ROOT ) }/tasks/installer_build.rake'; Lucie::Log.verbose = #{ Lucie::Log.verbose?.to_s }; ENV[ 'INSTALLER_NAME' ] = '#{ @installer.name }'; ARGV #{ verbose_option } << '--rakefile=#{ rakefile }' << 'installer:build'; Rake.application.run"}
  end


  def additional_artifacts
    return Dir.entries( artifacts_directory ).find_all do | each |
      !( each =~ IGNORE_ARTIFACTS )
    end
  end


  def output
    begin
      log = ''
      File.open( artifact( 'build.log' ), 'r' ) do | file |
        log = file.read
      end
      return log
    rescue
      return ''
    end
  end


  def artifact file_name
    return File.join( artifacts_directory, file_name )
  end


  def artifacts_directory
    return( @artifacts_dir ||= File.join( @installer.path, "build-#{ label }" ) )
  end


  def status
    return @status.to_s
  end


  def incomplete?
    return @status.incomplete?
  end


  def command
    return( installer.build_command or rake )
  end


  def in_clean_environment_on_local_copy &block
    # set OS variable LUCIE_BUILD_ARTIFACTS so that custom build tasks
    # know where to redirect installers.
    ENV[ 'LUCIE_BUILD_ARTIFACTS' ] = self.artifacts_directory
    # LUCIE_RAKE_TASK communicates to installer:build which task to
    # build (if self.rake_task is not set, installer:build will try to
    # be smart about it)
    ENV[ 'LUCIE_RAKE_TASK' ] = self.rake_task
    # Set RAILS_ROOT so that installer:build tasks can find kernel
    # packages and Lucie libraries.
    ENV[ 'RAILS_ROOT' ] = File.expand_path( RAILS_ROOT )

    Dir.chdir( installer.local_checkout ) do
      block.call
    end
  end


  def rake_task
    return installer.rake_task
  end


  def installer_settings
    begin
      log = ''
      File.open( artifact( 'lucie_config.rb' ) ) do | file |
        log = file.read
      end
      return log
    rescue
      return ''
    end
  end


  def run
    begin
      build_log = artifact( 'build.log' )
      File.open( artifact( 'lucie_config.rb' ), 'w' ) do | file |
        file << @installer.config_file_content
      end

      unless @installer.config_valid?
        raise ConfigError.new( @installer.error_message )
      end

      # build_command must be set before doing chdir, because there may
      # be some relative paths
      build_command = self.command
      time = Time.now
      @status.start!
      in_clean_environment_on_local_copy do
        lucie_daemon = DRbObject.new_with_uri( LucieDaemon.uri )
        lucie_daemon.sudo build_command, build_log
      end
      @status.succeed!( ( Time.now - time ).ceil )
    rescue => e
      File.open( build_log, 'a' ) do | file |
        file << e.message
      end
      Lucie::Log.verbose? ? Lucie::Log.debug(e) : Lucie::Log.info(e.message)
      time_escaped = ( Time.now - ( time || Time.now ) ).ceil
      if e.is_a?( ConfigError )
        @status.fail! time_escaped, e.message
      else
        @status.fail! time_escaped
      end
    end
  end


  def elapsed_time_in_progress
    @status.elapsed_time_in_progress
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
