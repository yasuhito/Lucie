require "ssh/process"


#
# <tt>scp</tt> with logging.
#
class SSH::CopyProcess < SSH::Process
  #
  # Creates a new CopyProcess object.
  #
  def initialize from, to, debug_options
    @from = from
    @to = to
    super debug_options
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
