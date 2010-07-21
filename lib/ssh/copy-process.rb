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


  ##############################################################################  
  private
  ##############################################################################  


  def default_handler
    lambda do | line |
      debug line
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
