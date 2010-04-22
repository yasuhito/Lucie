require "reek/rake/task"


#
# See the follwing URL for details:
# http://wiki.github.com/kevinrutherford/reek/rake-task
#
Reek::Rake::Task.new do | t |
  t.fail_on_error = true
  t.verbose = false
  t.reek_opts = "--quiet"
  t.source_files = "lib/**/*.rb"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
