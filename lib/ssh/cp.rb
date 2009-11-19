require "ssh-home"


class SSH
  class Cp
    include SSHHome


    def initialize from, to, debug_options
      @from = from
      @to = to
      @debug_options = debug_options
    end


    def run shell
      shell.on_stdout { | line | stdout.puts line }
      shell.on_stderr { | line | stderr.puts line }
      shell.exec command
    end


    ############################################################################
    private
    ############################################################################


    def command
      "scp -i #{ private_key_path } #{ SSH::OPTIONS } #{ @from } root@#{ @to }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
