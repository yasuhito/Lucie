module Scm
  class Common
    def initialize options
      @options = options
    end


    def name
      self.class.to_s.split( "::" ).last.downcase
    end


    ############################################################################
    private
    ############################################################################


    def run command, env = { "LC_ALL" => "C" }
      Popen3::Shell.open do | shell |
        shell.on_stdout do | line |
          ( @options[ :messenger ] || $stdout ).puts line
        end
        shell.on_stderr do | line |
          ( @options[ :messenger ] || $stderr ).puts line
        end
        shell.on_failure do
          raise "command #{ command } failed"
        end
        ( @options[ :messenger ] || $stderr ).puts command if verbose? || dry_run?
        shell.exec command, env unless dry_run?
      end
    end


    def whoami
      `whoami`.chomp
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
