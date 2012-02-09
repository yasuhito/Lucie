require "lucie"

require "lucie/log"
require "status/build"


class Build
  attr_reader :path
  attr_reader :status


  def initialize installer, path, options, messenger
    @installer = installer
    @path = path
    @options = options
    @messenger = messenger
    @status = Status::Build.new( @path, @options.merge( :messenger => @messenger ) )
    if @options[ :dry_run ]
      Lucie::Log.path = nil
    else
      Lucie::Log.path = build_log
    end
  end


  def label
    File.basename( @path )[ 6..-1 ]
  end


  def artifact file
    File.join @path, file
  end


  def run
    if @status.succeeded?
      rake_with_logging install_kernel_command
    else
      begin
        @status.start!
        rake_with_logging build_command
        @status.succeed!
      rescue => e
        Lucie::Log.error "failed: #{ build_command }"
        @status.fail!
      end
    end
  end


  ##############################################################################
  private
  ##############################################################################


  require "rbconfig"
  def ruby
    File.join( RbConfig::CONFIG[ "bindir" ], RbConfig::CONFIG[ "ruby_install_name" ] )
  end


  def rake_with_logging command
    Lucie::Log.debug command
    ( @messenger || $stderr ).puts command if @options[ :verbose ]
    return if @options[ :dry_run ]
    raise unless system( command )
  end


  def build_log
    File.join @path, "build.log"
  end


  def build_command
    %{sudo #{ ruby } -I#{ require_path } -e "require 'installer'; #{ set_env }; #{ setup_logging }; #{ build_argv }; Rake.application.run"}
  end


  def install_kernel_command
    %{sudo #{ ruby } -I#{ require_path } -e "require 'installer'; #{ set_env }; #{ setup_logging }; #{ install_kernel_argv }; Rake.application.run"}
  end


  def require_path
    File.join Lucie::ROOT, "lib"
  end


  def set_env
    verbose = @options[ :verbose ] ? "true" : "false"
    %{ENV[ 'LUCIE_USER' ] = '#{ `whoami`.chomp }'; ENV[ 'INSTALLER_NAME' ] = '#{ @installer.suite }'; ENV[ 'INSTALLER_PATH' ] = '#{ @installer.path }'; ENV[ 'VERBOSE' ] = '#{ verbose }'}
  end


  def setup_logging
    %{Lucie::Log.path = '#{ build_log }'}
  end


  def build_argv
    trace = %{<< '--trace' } if @options[ :verbose ]
    %{ARGV #{ trace }<< '--rakefile=#{ rakefile }' << 'installer:nfsroot'}
  end


  def install_kernel_argv
    trace = %{<< '--trace' } if @options[ :verbose ]
    %{ARGV #{ trace }<< '--rakefile=#{ rakefile }' << 'installer:install_nfsroot_kernel'}
  end


  def rakefile
    File.join @installer.path, "config.rb"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
