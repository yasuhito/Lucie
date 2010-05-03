require "ssh/path"


#
# A base class of SSH process.
#
class SSH::Process
  include SSH::Path


  def initialize logger, debug_options
    @logger = logger
    @debug_options = debug_options
  end


  def run
    SubProcess.create( @debug_options ) do | shell |
      begin
        set_handlers_for shell
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


  def set_handlers_for shell
    default_handler = lambda { | line | @logger.debug line }
    [ :on_stdout, :on_stderr ].each do | each |
      shell.__send__ each, &default_handler
    end
  end


  def spawn_subprocess shell, command
    @logger.debug command
    shell.exec command
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
