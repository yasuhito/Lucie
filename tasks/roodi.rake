require "rake/tasklib"
require "roodi"
require "roodi_task"


RoodiTask.new do | t |
  t.patterns = %w(lib/**/*.rb spec/**/*.rb features/**/*.rb)
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
