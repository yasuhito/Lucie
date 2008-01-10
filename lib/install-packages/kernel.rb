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
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
