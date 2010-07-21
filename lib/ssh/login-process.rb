require "ssh/process"


#
# login with SSH
#
class SSH::LoginProcess < SSH::Process
  #
  # Creates a new LoginProcess object. The following options are
  # available:
  #
  # <tt>:logger</tt>:: Save logs with the specified logger [nil]
  # <tt>:verbose</tt>:: Be verbose [nil]
  # <tt>:dry_run</tt>:: Print the commands that would be executed, but do not execute them. [nil]
  #
  # Usage:
  #   # login to yasuhito_desktop
  #   SSH::LoginProcess.new( "yasuhito_desktop" ).run
  #
  #   # login to yasuhito_desktop, with logging
  #   SSH::LoginProcess.new( "yasuhito_desktop", :logger => logger ).run
  #
  #   # login to yasuhito_desktop, verbose mode
  #   SSH::LoginProcess.new( "yasuhito_desktop", :verbose => true ).run
  #
  #   # login to yasuhito_desktop, dry-run mode
  #   SSH::LoginProcess.new( "yasuhito_desktop", :dry_run => true ).run
  #
  def initialize host_name, debug_options
    @host_name = host_name
    @debug_options = debug_options
  end


  #
  # Runs an ssh-login command
  #
  def run
    raise "`#{ real_command }' failed" unless Kernel.system( real_command )
  end


  ############################################################################
  private
  ############################################################################


  def real_command
    "ssh -i #{ private_key } #{ SSH::OPTIONS } root@#{ @host_name }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
