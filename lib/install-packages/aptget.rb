require 'install-packages/apt-package-manager'
require 'install-packages/package-manager'
require 'popen3/shell'


module InstallPackages
  class AptGet
    include AptPackageManager
    include PackageManager


    def initialize packageList = []
      @package_list = packageList
      @shell = Popen3::Shell.new
    end


    def clean options
      execute( @shell, "#{ chroot_command } apt-get clean", options )
    end


    def install options
      execute( @shell, "#{ chroot_command } apt-get #{ apt_option } --fix-missing install #{ @package_list.join( ' ' ) }", options )
      clean options
    end


    def remove options
      execute( @shell, "#{ chroot_command } apt-get #{ apt_option } --purge remove #{ @package_list.join( ' ' ) }", options )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
