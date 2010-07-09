# -*- coding: utf-8 -*-
Given /^ノード "([^\"]*)" のログディレクトリは "([^\"]*)"$/ do | node, node_log_dir |
  @node_log_dir = node_log_dir
  FileUtils.rm_rf @node_log_dir
  FileUtils.mkdir_p @node_log_dir
end


def node_install_log_dir_for install_id
  File.join @node_log_dir, "install-#{ install_id }"
end


Given /^インストール (\d+) 回目は (\d+) 秒かかって成功$/ do | install_id, seconds |
  FileUtils.mkdir node_install_log_dir_for( install_id )
  FileUtils.touch File.join( node_install_log_dir_for( install_id ), "installer_status.success.in#{ seconds }s" )
end


Given /^インストール (\d+) 回目は (\d+) 秒かかって失敗$/ do | install_id, seconds |
  FileUtils.mkdir node_install_log_dir_for( install_id )
  FileUtils.touch File.join( node_install_log_dir_for( install_id ), "installer_status.failed.in#{ seconds }s" )
end


Given /^インストール (\d+) 回目は実行中$/ do | install_id |
  FileUtils.mkdir node_install_log_dir_for( install_id )
  FileUtils.touch File.join( node_install_log_dir_for( install_id ), "installer_status.incomplete" )
end


Given /^インストール (\d+) 回目のログが消失$/ do | install_id |
  FileUtils.mkdir node_install_log_dir_for( install_id )
end


When /^ノード "([^\"]*)" に対して node history コマンドを実行した$/ do | node |
  @messenger = StringIO.new
  app = Command::NodeHistory::App.new( [], :messenger => @messenger, :node_log_dir => @node_log_dir )
  app.main node
end


When /^ノード "([^\"]*)" に対して node history コマンドを \-\-color オプション付きで実行した$/ do | node |
  @messenger = StringIO.new
  app = Command::NodeHistory::App.new( [ "--color" ], :messenger => @messenger, :node_log_dir => @node_log_dir )
  app.main node
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
