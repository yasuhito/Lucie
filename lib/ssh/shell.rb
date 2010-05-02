module SSH::Shell
  def set_handlers_for shell
    default_handler = lambda { | line | @output << line + "\n"; @logger.debug( line ) }
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
