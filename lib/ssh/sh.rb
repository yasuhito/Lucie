require "ssh/home"
require "ssh/shell"


class SSH
  class Sh
    include Home
    include Shell


    attr_reader :output


    def run host_name, command, shell
      set_handlers_for shell
      spawn_subprocess shell, real_command( host_name, command )
      self
    end


    ############################################################################
    private
    ############################################################################


    def real_command host_name, command
      %{ssh -i #{ private_key_path } #{ SSH::OPTIONS } root@#{ host_name } "#{ command }"}
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
