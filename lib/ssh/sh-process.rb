require "ssh/shell-process"


#
# ssh with logging
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
