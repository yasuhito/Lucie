#
# $Id: aptitude.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2


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


    def install_without_recommends dryRun = false
      execute( @shell, default_env, chroot_command + [ 'aptitude', '-R' ] + apt_option + [ 'install' ] + @package_list, dryRun )
      execute( @shell, default_env, chroot_command + [ 'apt-get', 'clean' ], dryRun )
    end


    def install_with_recommends dryRun = false
      execute( @shell, default_env, chroot_command + [ 'aptitude', '-r' ] + apt_option + [ 'install' ] + @package_list, dryRun )
      execute( @shell, default_env, chroot_command + [ 'apt-get', 'clean' ], dryRun )
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
