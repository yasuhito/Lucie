#
# builder_starter.rb - start builder process.
#
# methods:
#
#   BuilderStarter.run_builders_at_startup= - set flag whether run builder at startup or not
#   BuilderStarter.start_builders - start builders (examines run_builders_at_startup flag)
#   BuilderStarter.begin_builder - begin builder (force build)
#


class BuilderStarter
  @@run_builders_at_startup = true


  def self.run_builders_at_startup= value
    @@run_builders_at_startup = value
  end


  #
  # This method is invoked implicitly in
  # config/environments/production.rb loaded at startup of
  # 'production' environment commandline tools.
  #
  def self.start_builders
    if @@run_builders_at_startup
      Installers.load_all.each do | installer |
        begin_builder installer.name
      end
    end
  end


  def self.begin_builder installer_name
    verbose_option = $VERBOSE_MODE ? '--trace' : ''

    pid = fork || exec( "#{ RAILS_ROOT }/installer build #{ installer_name } #{ verbose_option }" )
    installer_pid_location = "#{ RAILS_ROOT }/tmp/pids/builders"

    FileUtils.mkdir_p installer_pid_location
    File.open( File.join( installer_pid_location, installer_name + '.pid' ), 'w' ) do | f |
      f.write pid
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
