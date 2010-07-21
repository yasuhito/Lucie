require "ssh/process"


#
# SSH with logging
#
class SSH::ShellProcess < SSH::Process
  attr_reader :output


  #
  # Creates a new ShellProcess object.
  #
  def initialize host_name, command_line, debug_options
    @output = ""
    @host_name = host_name
    @command_line = command_line
    super debug_options
  end


  ##############################################################################  
  private
  ##############################################################################  


  def default_handler
    lambda do | line |
      @output << line + "\n"
      debug line
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
