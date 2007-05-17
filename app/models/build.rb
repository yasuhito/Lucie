#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


class Build
  include CommandLine


  IGNORE_ARTIFACTS = /^(\..*|build_status\..+|build.log|changeset.log|installer_config.rb|plugin_errors.log)$/


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


  def brief_error
    if File.size(@status.status_file) > 0
      return "config error"
    end
    unless plugin_errors.empty?
      return "plugin error"
    end
    nil
  end


  def url
    dashboard_url = Configuration.dashboard_url
    if dashboard_url.nil? || dashboard_url.empty?
      raise 'Configuration.dashboard_url is not specified'
    end
    dashboard_url + ActionController::Routing::Routes.generate( :controller => 'builds', :action => 'show', :installer => installer, :build => to_param )
  end


  def failed?
    @status.failed?
  end


  def successful?
    @status.succeeded?
  end


  def to_param
    self.label
  end


  # XXX: invoke nfsroot task
  def rake
    # --nosearch flag here prevents CC.rb from building itself when a installer has no Rakefile
    %{ruby -e "require 'rubygems' rescue nil; require 'rake'; load '#{ File.expand_path( RAILS_ROOT ) }/tasks/cc_build.rake'; ARGV << '--nosearch' << 'cc:build'; Rake.application.run"}
  end


  def additional_artifacts
    Dir.entries(artifacts_directory).find_all do |artifact|
      !(artifact =~ IGNORE_ARTIFACTS)
    end
  end


  def output
    begin
      return File.read( artifact( 'build.log' ) )
    rescue
      return ''
    end
  end


  def artifact file_name
    return File.join( artifacts_directory, file_name )
  end


  def artifacts_directory
    @artifacts_dir ||= File.join( @installer.path, "build-#{label}" )
  end


  def status
    return @status.to_s
  end


  def incomplete?
    return @status.incomplete?
  end


  def command
    installer.build_command or rake
  end


  def in_clean_environment_on_local_copy &block
    # set OS variable CC_BUILD_ARTIFACTS so that custom build tasks know where to redirect their products
    ENV[ 'CC_BUILD_ARTIFACTS' ] = self.artifacts_directory
    # CC_RAKE_TASK communicates to cc:build which task to build (if self.rake_task is not set, cc:build will try to be
    # smart about it)
    ENV[ 'CC_RAKE_TASK' ] = self.rake_task
    Dir.chdir( installer.local_checkout ) do
      block.call
    end
  end


  def rake_task
    installer.rake_task
  end


  def installer_settings
    File.read( artifact( 'installer_config.rb' ) ) rescue ''
  end


  def run
    build_log = artifact 'build.log'
    File.open( artifact('installer_config.rb'), 'w') do |f|
      f << @installer.config_file_content
    end
    
    unless @installer.config_valid?
      raise ConfigError.new( @installer.error_message )
    end
    
    # build_command must be set before doing chdir, because there may be some relative paths
    build_command = self.command
    time = Time.now
    @status.start!
    in_clean_environment_on_local_copy do
      execute build_command, :stdout => build_log, :stderr => build_log, :escape_quotes => false
    end
    @status.succeed!((Time.now - time).ceil)    

    rescue => e
    if File.exists?( installer.local_checkout + "/trunk" )
      msg = <<-MESSAGE

WARNING:
Directory #{installer.local_checkout}/trunk exists. 
Maybe that's your APP_ROOT directory. 
Try to remove this installer, then re-add it with correct APP_ROOT, e.g.

rm -rf #{installer.path}
./installer add #{installer.name} svn://my.svn.com/#{installer.name}/trunk
MESSAGE
      File.open(build_log, 'a'){|f| f << msg }
    end
    File.open(build_log, 'a'){|f| f << e.message }
#    CruiseControl::Log.verbose? ? CruiseControl::Log.debug(e) : CruiseControl::Log.info(e.message)
    time_escaped = (Time.now - (time || Time.now)).ceil
    if e.is_a? ConfigError
      @status.fail!(time_escaped, e.message)
    else
      @status.fail!(time_escaped)
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
