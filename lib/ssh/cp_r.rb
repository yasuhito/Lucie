require "ssh/cp"


class SSH
  class Cp_r < Cp
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
