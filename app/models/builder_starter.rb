#
# builder_starter.rb - start builder process.
#
# Methods:
#
#   BuilderStarter.run_builders_at_startup= - set flag whether run builder at start up or not
#   BuilderStarter.start_builders - start builders (examines run_builders_at_startup flag)
#   BuilderStarter.begin_builder - begin builder (force build)
#


class BuilderStarter
  @@run_builders_at_startup = true


  def self.run_builders_at_startup= value
    @@run_builders_at_startup = value
  end


  #
  # Start builders for all the registered installers.
  #
  # NOTE: This method is invoked from
  # config/environments/production.rb, loaded at start up of
  # 'production' environment command-line tools.
  #
  def self.start_builders
    if @@run_builders_at_startup
      Installers.load_all.each do | each |
        begin_builder each.name
      end
    end
  end


  #
  # Start a builder process for a installer.
  #
  # [FIXME] Who sets $VERBOSE_MODE flag?
  #
  def self.begin_builder installer_name
    verbose_option = $VERBOSE_MODE ? ' --trace' : ''
    pid_dir = "#{ RAILS_ROOT }/tmp/pids/builders"
    pid_path = File.join( pid_dir, installer_name + '.pid' )

    pid = fork || exec( "#{ RAILS_ROOT }/installer build #{ installer_name }#{ verbose_option }" )

    FileUtils.mkdir_p pid_dir
    File.open( pid_path, 'w' ) do | f |
      f.write pid
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
