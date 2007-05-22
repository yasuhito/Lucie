#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


class BuilderStarter
  @@run_builders_at_startup = true


  def self.run_builders_at_startup=(value)
    @@run_builders_at_startup = value
  end


  def self.start_builders
    if @@run_builders_at_startup
      Installers.load_all.each do |installer|
        begin_builder installer.name
      end
    end
  end


  def self.begin_builder(installer_name)
    verbose_option = $VERBOSE_MODE ? "--trace" : ""
    if Platform.family == 'mswin32'
      Thread.new(installer_name) { |my_installer_name| system("installer.cmd build #{installer_name} #{verbose_option}") }
    else
      pid = fork || exec("#{RAILS_ROOT}/installer build #{installer_name} #{verbose_option}")
      installer_pid_location = "#{RAILS_ROOT}/tmp/pids/builders"
      FileUtils.mkdir_p installer_pid_location
      File.open("#{installer_pid_location}/#{installer_name}.pid", "w") {|f| f.write pid }
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
