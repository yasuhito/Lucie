module SubProcess
  class Command
    attr_reader :command
    attr_reader :env


    def initialize command, env = {}
      @command = command
      @env = env
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
