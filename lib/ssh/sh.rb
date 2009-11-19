require "ssh/shell-command"


class SSH
  class Sh
    include ShellCommand


    def run shell, logger
      output = []
      shell.on_stdout do | line | 
        stdout.puts line
        logger.debug line
        output << line
      end
      shell.on_stderr do | line |
        stderr.puts line
        logger.debug line
      end
      shell.on_failure do
        raise "command #{ @command } failed on #{ @ip }"
      end
      logger.debug real_command
      shell.exec real_command
      output
    end


    ############################################################################
    private
    ############################################################################


    def real_command
      %{ssh -i #{ private_key_path } #{ SSH::OPTIONS } root@#{ @ip } "#{ @command }"}
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
