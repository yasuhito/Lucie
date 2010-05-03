# Allows you to spawn processes and connect to their output/error
# pipes and obtain their return codes.
#
# == Example:
#
#  SubProcess.create do | shell |
#    # Add some hooks here
#    shell.on_...
#    shell.on_...
#      ...
#
#    # Finally spawn a subprocess
#    shell.exec command
#  end
#
# == Hooks:
#
# <tt>on_stdout</tt>:: Executed when a new line arrived from sub-process's stdout.
# <tt>on_stderr</tt>:: Executed when a new line arrived from sub-process's stderr.
# <tt>on_exit</tt>:: Executed when sub process exitted.
# <tt>on_success</tt>:: Executed when sub process exitted successfully.
# <tt>on_failure</tt>:: Executed when sub process aborted.
#
# *WARNING*: If you need to spawn subprocesses in your code, require
# this file with:
#
#  require "sub-process"
#
# instead of requiring sub-process/*.rb directly.
#
module SubProcess
  require "sub-process/command"
  require "sub-process/process"
  require "sub-process/shell"


  def create debug_options = {}, &block
    Shell.open debug_options, &block
  end
  module_function :create
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
