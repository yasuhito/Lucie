class SSH
  class Sh
    def initialize ip, command, priv_key
      @ip = ip
      @command = command
      @priv_key = priv_key
      @output = []
    end


    def run shell
      shell.on_stdout do | line | 
        @output << line
      end
      shell.on_failure do
        raise "command #{ @command } failed on #{ @ip }"
      end
      shell.exec real_command
      @output
    end


    ############################################################################
    private
    ############################################################################


    def real_command
      %{ssh -i #{ @priv_key } #{ SSH::OPTIONS } root@#{ @ip } "#{ @command }"}
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
