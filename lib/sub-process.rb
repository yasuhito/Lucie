#
# Spawns a process and connect pipes to its stdout/stderr and obtain
# its exit code.
#
# == Example:
#
#  SubProcess.create do | shell |
#    # Add some hooks here
#    shell.on_stdout do | line |
#      log line
#      $stdout.puts line
#    end
#    shell.on_stderr do | line |
#      log line
#      $stderr.puts line
#    end
#    shell.on_failure do
#      raise "'#{ command }' failed."
#    end
#
#    # Spawn a subprocess
#    shell.exec command
#  end
#
# == Hooks:
#
# <tt>on_stdout</tt>:: Executed when a new line arrived from sub-process's stdout.
# <tt>on_stderr</tt>:: Executed when a new line arrived from sub-process's stderr.
# <tt>on_exit</tt>:: Executed when sub process exited.
# <tt>on_success</tt>:: Executed when sub process exited successfully.
# <tt>on_failure</tt>:: Executed when sub process exited with an error.
#
# *WARNING*: Require this file with:
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
