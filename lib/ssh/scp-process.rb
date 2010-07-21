require "ssh/copy-process"


#
# Copy a file via SSH. The following options are available:
#
# <tt>:logger</tt>:: Save logs with the specified logger [nil]
# <tt>:verbose</tt>:: Be verbose [nil]
# <tt>:dry_run</tt>:: Print the commands that would be executed, but do not execute them. [nil]
#
# Usage:
#
#   # run `ls /home' on yasuhito_desktop
#   SSH::ScpProcess.new( "/tmp/log.txt", "yasuhito_desktop:/home/yasuhito" ).run
#
#   # run `ls /home' on yasuhito_desktop, with logging
#   SSH::ScpProcess.new( "/tmp/log.txt", "yasuhito_desktop:/home/yasuhito", :logger => logger ).run
#
#   # run `ls /home' on yasuhito_desktop, verbose mode
#   SSH::ScpProcess.new( "/tmp/log.txt", "yasuhito_desktop:/home/yasuhito", :verbose => true ).run
#
#   # run `ls /home' on yasuhito_desktop, dry-run mode
#   SSH::ScpProcess.new( "/tmp/log.txt", "yasuhito_desktop:/home/yasuhito", :dry_run => true ).run
#
class SSH::ScpProcess < SSH::CopyProcess
  ##############################################################################
  private
  ##############################################################################


  def real_command
    "scp -i #{ private_key } #{ SSH::OPTIONS } #{ @from } #{ @to }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
