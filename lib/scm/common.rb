module Scm
  class Common
    def initialize options
      @options = options
    end


    def name
      self.class.to_s.split( "::" ).last.downcase
    end
    alias to_s name


    ############################################################################
    private
    ############################################################################


    def run command, env = { "LC_ALL" => "C" }
      Popen3::Shell.open do | shell |
        messenger.puts command if verbose? || dry_run?
        shell.exec command, env unless dry_run?
      end
    end


    def messenger
      @options[ :messenger ] || $stderr
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
