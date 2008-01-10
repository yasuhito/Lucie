require 'install-packages/command'


module InstallPackages
  class InstallCommand
    def initialize aptget
      @aptget = aptget
    end


    def execute options
      @aptget.install options
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
