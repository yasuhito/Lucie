require "service/common"

require "service/approx"
require "service/debootstrap"
require "service/dhcp"
require "service/installer"
require "service/nfs"
require "service/tftp"


module Service
  def all
    list = []
    ObjectSpace.each_object( Class ) do | each |
      next if each.superclass != Service::Common
      list << each
    end
    list
  end
  module_function :all


  def check_prerequisites debug_options
    not_installed = PrerequisiteChecker.new( debug_options ).missing_packages_for( all )
    unless not_installed.empty?
      error_message = "#{ not_installed.join( ', ' ) } not installed. Try 'aptitude install #{ not_installed.join( ' ' ) }'"
      if debug_options[ :dry_run ]
        ( debug_options[ :messenger ] || $stderr ).puts error_message if debug_options[ :verbose ]
      else
        raise error_message
      end
    end
  end
  module_function :check_prerequisites
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
