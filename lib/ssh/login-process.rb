require "ssh/path"


#
# ssh login
#
class SSH::LoginProcess # :nodoc:
  include SSH::Path


  def initialize host_name, debug_options
    @host_name = host_name
    @debug_options = debug_options
  end


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
