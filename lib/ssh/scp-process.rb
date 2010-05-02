require "ssh/process"


#
# scp with logging.
#
class SSH::ScpProcess < SSH::Process
  def initialize from, to, logger, debug_options
    @from = from
    @to = to
    super logger, debug_options
  end


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
