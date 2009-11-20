require "ssh/home"
require "ssh/shell"


class SSH
  class Sh
    include Home
    include Shell


    attr_reader :output


    def run ip, command, shell
      set_stdout_handler_for shell
      set_stderr_handler_for shell
      spawn_subprocess shell, real_command( ip, command )
      self
    end


    ############################################################################
    private
    ############################################################################


    def real_command ip, command
      %{ssh -i #{ private_key_path } #{ SSH::OPTIONS } root@#{ ip } "#{ command }"}
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
