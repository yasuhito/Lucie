require "lucie/debug"
require "ssh/path"


#
# A base class of SSH process.
#
class SSH::Process
  include SSH::Path


  #
  # Creates a new SSH process object. The following options are
  # available:
  #
  # <tt>:logger</tt>:: Save logs with the specified logger [nil]
  # <tt>:verbose</tt>:: Be verbose [nil] 
  # <tt>:dry_run</tt>:: Print the commands that would be executed, but do not execute them. [nil]
  # 
  # Usage:
  #
  #   # scp
  #   scp = SSH::ScpProcess.new( "/tmp/data.txt", "yasuhito:/tmp" )
  #
  #   # scp, with logging
  #   scp = SSH::ScpProcess.new( "/tmp/data.txt", "yasuhito:/tmp", :logger => logger )
  #
  #   # scp, verbose mode
  #   scp = SSH::ScpProcess.new( "/tmp/data.txt", "yasuhito:/tmp", :verbose => true )
  #
  #   # scp, dry-run mode
  #   scp = SSH::ScpProcess.new( "/tmp/data.txt", "yasuhito:/tmp", :dry_run => true )
  #
  def initialize debug_options
    @logger = debug_options[ :logger ]
    @debug_options = debug_options
  end


  #
  # Runs an SSH process.
  #
  # Usage:
  #
  #   SSH::ScpProcess.new( "/tmp/data.txt", "yasuhito:/tmp" ).run
  #
  def run
    SubProcess.create( @debug_options ) do | shell |
      begin
        set_default_handlers_for shell
        spawn_subprocess shell, real_command
      ensure
        post_command_hook shell
      end
    end
    self
  end


  ##############################################################################
  private
  ##############################################################################


  def real_command
    raise NotImplementedError
  end


  def post_command_hook shell
    # do nothing
  end


  def set_default_handlers_for shell
    [ :on_stdout, :on_stderr ].each do | each |
      shell.__send__ each, &default_handler
    end
  end


  def default_handler
    lambda do | line |
      @output << line + "\n"
      debug line
    end
  end


  def spawn_subprocess shell, command
    debug command
    shell.exec command
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
