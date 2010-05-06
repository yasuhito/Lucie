require "ssh/copy-process"


#
# scp with logging.
#
class SSH::ScpProcess < SSH::CopyProcess # :nodoc:
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
