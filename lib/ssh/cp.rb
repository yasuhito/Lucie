require "ssh/home"


class SSH
  class Cp
    include Home


    def run from, to, shell, logger
      shell.on_stdout do | line |
        logger.debug line
      end
      shell.on_stderr do | line |
        logger.debug line
      end
      logger.debug command( from, to )
      shell.exec command( from, to )
    end


    ############################################################################
    private
    ############################################################################


    def command from, to
      "scp -i #{ private_key_path } #{ SSH::OPTIONS } #{ from } #{ to }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
