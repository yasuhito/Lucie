require "sub-process/pipe-set"


module SubProcess
  #
  # Forks a sub-process and creates pipes for IPC.
  #
  class Process # :nodoc:
    #
    # Creates a new SubProcess::Process object.
    #
    def initialize
      stdin, stdout, stderr = Array.new( 3 ) { IO.pipe }
      @child = PipeSet.new( stdin[ 1 ], stdout[ 0 ], stderr[ 0 ] )
      @parent = PipeSet.new( stdin[ 0 ], stdout[ 1 ], stderr[ 1 ] )
    end


    #
    # Waits for and returns the pid of the subprocess.
    #
    def wait
      ::Process.wait @pid
    end


    #
    # Executes command as subprocess. Standard out and error from the
    # subprocess are passed as block arguments.
    #
    def popen command, &block
      @pid = fork_child( command )
      # Parent process
      @parent.close
      begin
        yield @child.stdout, @child.stderr
      ensure
        @child.close
      end
      self
    end


    ############################################################################
    private
    ############################################################################


    def fork_child command
      Kernel.fork do
        @child.close
        redirect_child_io
        command.start
      end
    end


    def redirect_child_io
      STDIN.reopen @parent.stdin
      STDOUT.reopen @parent.stdout
      STDERR.reopen @parent.stderr
      @parent.close
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
