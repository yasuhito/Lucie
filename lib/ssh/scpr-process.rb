require "ssh/copy-process"


#
# scp -r with logging.
#
class SSH::ScprProcess < SSH::CopyProcess
  ##############################################################################
  private
  ##############################################################################


  def real_command
    "scp -i #{ private_key } #{ SSH::OPTIONS } -r #{ @from } #{ @to }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
