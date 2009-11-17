require "sub-process"


class Scm
  class Common
    def initialize debug_options = {}
      @debug_options = debug_options
    end


    def name
      self.class.to_s.split( "::" ).last.downcase
    end


    def test_installed
      unless Dpkg.new( @debug_options ).installed?( name )
        raise "#{ self } is not installed"
      end
    end


    def test_installed_on node
      unless Dpkg.new( @debug_options ).installed_on?( node, name )
        raise "#{ self } is not installed on #{ node.name }"
      end
    end


    ############################################################################
    private
    ############################################################################


    def run command, env = { "LC_ALL" => "C" }
      SubProcess::Shell.open do | shell |
        shell.on_stdout do | line |
          ( @debug_options[ :messenger ] || $stdout ).puts line
        end
        shell.on_stderr do | line |
          ( @debug_options[ :messenger ] || $stderr ).puts line
        end
        shell.on_failure do
          raise "command #{ command } failed"
        end
        ( @debug_options[ :messenger ] || $stderr ).puts command if verbose? || dry_run?
        shell.exec command, env unless dry_run?
      end
    end


    def whoami
      `whoami`.chomp
    end


    def verbose?
      @debug_options[ :verbose ]
    end


    def dry_run?
      @debug_options[ :dry_run ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
