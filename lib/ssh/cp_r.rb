require "ssh/home"


class SSH
  class Cp_r
    include Home


    def command from, to
      "scp -i #{ private_key_path } #{ SSH::OPTIONS } -r #{ from } #{ to }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
