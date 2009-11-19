require "ssh-home"


class SSH
  module ShellCommand
    include SSHHome


    def initialize ip, command, debug_options
      @ip = ip
      @command = command
      @debug_options = debug_options
    end


    ############################################################################
    private
    ############################################################################


    def real_command
      raise NotImplementedError
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
