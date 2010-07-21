require "ssh/shell-process"


#
# Run a command via SSH. The following options are available:
#
# <tt>:logger</tt>:: Save logs with the specified logger [nil]
# <tt>:verbose</tt>:: Be verbose [nil] 
# <tt>:dry_run</tt>:: Print the commands that would be executed, but do not execute them. [nil]
#
# Usage:
#
#   # run `ls /home' on yasuhito_desktop
#   SSH::ShProcess.new( "yasuhito_desktop", "ls /home" ).run
#
#   # run `ls /home' on yasuhito_desktop, with logging
#   SSH::ShProcess.new( "yasuhito_desktop", "ls /home", :logger => logger ).run
#
#   # run `ls /home' on yasuhito_desktop, verbose mode
#   SSH::ShProcess.new( "yasuhito_desktop", "ls /home", :verbose => true ).run
#
#   # run `ls /home' on yasuhito_desktop, dry-run mode
#   SSH::ShProcess.new( "yasuhito_desktop", "ls /home", :dry_run => true ).run
#   
class SSH::ShProcess < SSH::ShellProcess
  ############################################################################
  private
  ############################################################################


  def real_command
    %{ssh -i #{ private_key } #{ SSH::OPTIONS } root@#{ @host_name } "#{ @command_line }"}
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
