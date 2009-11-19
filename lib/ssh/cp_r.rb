class SSH
  class Cp_r
    def initialize from, to, private_key_path, debug_options
      @from = from
      @to = to
      @private_key_path = private_key_path
      @debug_options = debug_options
    end


    def run shell
      command = "scp -i #{ @private_key_path } #{ SSH::OPTIONS } -r #{ @from } root@#{ @to }"
      shell.on_stdout do | line |
        stdout.puts line
      end
      shell.on_stderr do | line |
        stderr.puts line
      end
      shell.on_failure do
        raise "command #{ command } failed"
      end
      shell.exec command
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
