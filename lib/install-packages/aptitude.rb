require 'install-packages/apt-package-manager'
require 'install-packages/package-manager'
require 'popen3/shell'


module InstallPackages
  class Aptitude
    include AptPackageManager
    include PackageManager


    def initialize packageList
      @package_list = packageList
      @shell = Popen3::Shell.new
    end


    def install_without_recommends options
      execute( @shell, "#{ chroot_command } aptitude -R #{ apt_option } install #{ @package_list.join( ' ' )}", options )
      execute( @shell, "#{ chroot_command } apt-get clean", options )
    end


    def install_with_recommends options
      execute( @shell, "#{ chroot_command } aptitude -r #{ apt_option } install #{ @package_list.join( ' ' )}", options )
      execute( @shell, "#{ chroot_command } apt-get clean", options )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
