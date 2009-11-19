require "ssh-home"


class SSH
  module CopyCommand
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
      raise NotImplementedError
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
