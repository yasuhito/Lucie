require "ssh/process"


#
# scp with logging.
#
class SSH::CopyProcess < SSH::Process # :nodoc:
  def initialize from, to, logger, debug_options
    @from = from
    @to = to
    super logger, debug_options
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
