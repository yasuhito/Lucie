require "rake/tasklib"
require "flay"
require "flay_task"


FlayTask.new do | t |
  t.dirs = %w( lib script )
  t.threshold = 0
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
