require "ssh/process"


#
# ssh with logging
#
class SSH::ShellProcess < SSH::Process
  attr_reader :output


  def initialize host_name, command_line, logger, debug_options
    @host_name = host_name
    @command_line = command_line
    @output = ""
    super logger, debug_options
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
