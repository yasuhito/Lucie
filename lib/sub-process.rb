#
# SubProcess module allows you to spawn processes and connect to their
# output/error pipes and obtain their return codes.
#
# If you need to spawn subprocesses in your code, require this file
# with:
#
#  require "sub-process"
#
# instead of requiring sub-process/*.rb directly.
#


module SubProcess; end


require "sub-process/command"
require "sub-process/process"
require "sub-process/shell"


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
