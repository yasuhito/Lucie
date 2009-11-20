require "ssh/home"


class SSH
  class Sh
    include Home


    def run ip, command, shell, logger
      output = StringIO.new
      shell.on_stdout do | line |
        output.puts line
        logger.debug line
      end
      shell.on_stderr do | line |
        output.puts line
        logger.debug line
      end
      logger.debug real_command( ip, command )
      shell.exec real_command( ip, command )
      output.string
    end


    def real_command ip, command
      %{ssh -i #{ private_key_path } #{ SSH::OPTIONS } root@#{ ip } "#{ command }"}
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
