#
# $Id: aptget.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2


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


    def clean dryRun = false
      execute( @shell, default_env, chroot_command + [ 'apt-get', 'clean' ], dryRun )
    end


    def install dryRun = false
      execute( @shell, default_env, chroot_command + [ 'apt-get' ] + apt_option + [ '--fix-missing', 'install' ] + @package_list, dryRun )
      clean dryRun
    end


    def remove dryRun = false
      execute( @shell, default_env, chroot_command + [ 'apt-get' ] + apt_option + [ '--purge', 'remove' ] + @package_list, dryRun )
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
