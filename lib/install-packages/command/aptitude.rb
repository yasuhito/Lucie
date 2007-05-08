#
# $Id: aptitude.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2


require 'install-packages/command'


module InstallPackages
  class AptitudeCommand
    include Command


    def initialize aptitude
      @aptitude = aptitude
    end


    def execute dryRun = false
      @aptitude.install_without_recommends dryRun
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
