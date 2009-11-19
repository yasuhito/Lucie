require "ssh/copy-command"


class SSH
  class Cp_r
    include CopyCommand


    ############################################################################
    private
    ############################################################################


    def command
      "scp -i #{ private_key_path } #{ SSH::OPTIONS } -r #{ @from } root@#{ @to }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
