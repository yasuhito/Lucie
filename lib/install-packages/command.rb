#
# $Id: command.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2


module InstallPackages
  module Command
    def execute
      raise NotImplementedError
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
