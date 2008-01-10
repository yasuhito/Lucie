require 'install-packages/command'


module InstallPackages
  class RemoveCommand
    include Command


    def initialize aptget
      @aptget = aptget
    end


    def execute options
      @aptget.remove options
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
