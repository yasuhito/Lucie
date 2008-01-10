require 'install-packages/command'
require 'popen3/shell'


module InstallPackages
  class AptitudeRCommand
    include Command


    def initialize aptitude
      @aptitude = aptitude
    end


    def execute dryRun = false
      @aptitude.install_with_recommends dryRun
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
