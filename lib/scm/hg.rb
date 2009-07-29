module Scm
  class Hg
    def initialize options
      @options = options
    end


    def clone url, target
      run %{hg clone --ssh "ssh -i #{ SSH::PRIVATE_KEY }" #{ url } #{ target }}
    end


    ############################################################################
    private
    ############################################################################


    def run command
      Popen3::Shell.open do | shell |
        messenger.puts command if verbose?
        shell.exec command unless dry_run?
      end
    end


    def messenger
      @options[ :messenger ]
    end


    def verbose?
      @options[ :verbose ]
    end


    def dry_run?
      @options[ :dry_run ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
