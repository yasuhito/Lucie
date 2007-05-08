#
# $Id: kernel.rb 1126 2007-04-09 08:00:47Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1126 $
# License::  GPL2


require 'install-packages/app'


#
# パッケージインストール設定 DSL 用の関数定義
#
module Kernel
  def aptget_install *packages
    InstallPackages::App.instance.add_command :aptget_install, packages
  end


  def aptget_remove *packages
    InstallPackages::App.instance.add_command :aptget_remove, packages
  end


  def aptget_clean
    InstallPackages::App.instance.add_command :aptget_clean
  end


  def aptitude *packages
    InstallPackages::App.instance.add_command :aptitude, packages
  end


  def aptitude_r *packages
    InstallPackages::App.instance.add_command :aptitude_r, packages
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
