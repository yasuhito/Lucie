require "ssh/copy-command"


class SSH
  class Cp
    include CopyCommand


    ############################################################################
    private
    ############################################################################


    def command
      "scp -i #{ private_key_path } #{ SSH::OPTIONS } #{ @from } #{ @to }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
