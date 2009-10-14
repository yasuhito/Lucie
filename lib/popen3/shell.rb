require "English"


module Popen3
  class Shell
    def self.open
      shell = self.new
      if block_given?
        yield shell
      end
    end


    def child_status
      $CHILD_STATUS
    end


    def on_exit &block
      @on_exit = block
    end


    def on_stdout &block
      @on_stdout = block
    end


    def on_stderr &block
      @on_stderr = block
    end


    def on_success &block
      @on_success = block
    end


    def on_failure &block
      @on_failure = block
    end


    def exec command, env = {}
      process = Popen3.new( command, env )
      process.popen3 do | stdin, stdout, stderr |
        @stdout, @stderr = stdout, stderr
        handle_child_output
      end
      process.wait
      do_exit
      handle_exitstatus
    end


    ############################################################################
    private
    ############################################################################


    def handle_child_output
      stdout_thread.join
      stderr_thread.join
    end


    def stdout_thread
      t = Thread.new do
        while line = @stdout.gets do
          do_stdout line.chomp
        end
      end
      t.priority = -10
      t
    end


    def stderr_thread
      t = Thread.new do
        while line = @stderr.gets do
          do_stderr line.chomp
        end
      end
      t.priority = -10
      t
    end


    # run hooks ################################################################


    def handle_exitstatus
      if child_status.exitstatus == 0
        do_success
      else
        do_failure
      end
    end


    def do_stdout line
      if @on_stdout
        @on_stdout.call line
      end
    end


    def do_stderr line
      if @on_stderr
        @on_stderr.call line
      end
    end


    def do_failure
      if @on_failure
        @on_failure.call
      end
    end


    def do_success
      if @on_success
        @on_success.call
      end
    end


    def do_exit
      if @on_exit
        @on_exit.call
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
