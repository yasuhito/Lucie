# this plugin prints major events like builds starting / passing / failing to console
#
# it is useful in debugging
#
# (this plugin is built in and needs no customization)
#
class MinimalConsoleLogger
  def initialize(installer)
  end

  def build_started(build)
    puts "Build #{build.label} started"
  end

  def build_finished(build)
    puts "Build #{build.label} " + (build.successful? ? 'finished SUCCESSFULLY' : 'FAILED')
  end

  def new_revisions_detected(new_revisions)
    puts "New revision #{new_revisions.last.number} detected"
  end

  def build_loop_failed(error)
    puts "Build loop failed" rescue nil
    puts "#{error.class}: #{error.message}" rescue nil
    puts error.backtrace.map { |line| "  #{line}" }.join("\n") rescue nil
  end

  def configuration_modified
    puts "Configuration modification detected"
  end
end

Installer.plugin :minimal_console_logger


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
