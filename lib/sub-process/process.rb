require "sub-process/pipe-set"


module SubProcess
  class Process
    #
    # Creates a new SubProcess::Process object.
    #
    def initialize
      rd_stdin, wr_stdin = IO.pipe
      rd_stdout, wr_stdout = IO.pipe
      rd_stderr, wr_stderr = IO.pipe
      @child = PipeSet.new( wr_stdin, rd_stdout, rd_stderr )
      @parent = PipeSet.new( rd_stdin, wr_stdout, wr_stderr )
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
