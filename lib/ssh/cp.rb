require "ssh/path"


class SSH
  class Cp
    include Path


    def command from, to
      "scp -i #{ private_key } #{ SSH::OPTIONS } #{ from } #{ to }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
