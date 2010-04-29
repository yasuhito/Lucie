require "English"
require "lucie/debug"
require "sub-process/io-handler-thread"


module SubProcess
  #
  # Spawns a sub-process and registers handlers for standard IOs and
  # process exit events.
  #
  class Shell
    include Lucie::Debug


    #
    # Calls the block passed as an argument with a new
    # SubProcess::Shell object.
    #
    # _Example:_
    #  SubProcess::Shell.open do | shell |
    #    # Add some hooks here
    #    shell.on_...
    #    shell.on_...
    #      ...
    #
    #    # Finally spawn a subprocess
    #    shell.exec command
    #  end
    #
    def self.open debug_options = {}, &block
      block.call self.new( debug_options )
    end


    def initialize debug_options # :nodoc:
      @debug_options = debug_options
    end


    #
    # Returns the status code of the subprocess. The status code
    # encodes both the return code of the process and information
    # about whether it exited using the exit() or died due to a
    # signal. Functions to help interpret the status code are defined
    # in Process::Status class.
    #
    def child_status
      $CHILD_STATUS
    end


    #
    # Registers a block that is called when the subprocess outputs a
    # line to standard out.
    #
    def on_stdout &block
      @on_stdout = block
    end


    #
    # Registers a block that is called when the subprocess outputs a
    # line to standard error.
    #
    def on_stderr &block
      @on_stderr = block
    end


    #
    # Registers a block that is called when the subprocess exits.
    #
    def on_exit &block
      @on_exit = block
    end


    #
    # Registers a block that is called when the subprocess exits
    # successfully.
    #
    def on_success &block
      @on_success = block
    end


    #
    # Registers a block that is called when the subprocess exits
    # abnormally.
    #
    def on_failure &block
      @on_failure = block
    end


    #
    # Spawns a subprocess with specified environment variables.
    #
    def exec command, env = {}
      debug command
      return if dry_run
      on_failure { raise "command #{ command } failed" } unless @on_failure
      Process.new.popen Command.new( command, env ) do | stdout, stderr |
        handle_child_output stdout, stderr
      end.wait
      handle_exitstatus
    end


    ############################################################################
    private
    ############################################################################


    def handle_child_output stdout, stderr
      tout = IoHandlerThread.new( stdout, method( :do_stdout ) )
      terr = IoHandlerThread.new( stderr, method( :do_stderr ) )
      tout.join
      terr.join
    end


    # run hooks ################################################################


    def handle_exitstatus
      do_exit
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
