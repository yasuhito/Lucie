require "ssh/path"


class SSH
  class CpRecursive
    include Path


    def command from, to
      "scp -i #{ private_key } #{ SSH::OPTIONS } -r #{ from } #{ to }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
