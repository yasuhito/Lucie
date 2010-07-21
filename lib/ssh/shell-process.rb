require "ssh/process"


#
# SSH with logging
#
class SSH::ShellProcess < SSH::Process
  #
  # Creates a new ShellProcess object.
  #
  def initialize host_name, command_line, debug_options
    @host_name = host_name
    @command_line = command_line
    super debug_options
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
