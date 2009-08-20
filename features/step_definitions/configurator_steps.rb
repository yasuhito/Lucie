# -*- coding: utf-8 -*-
Given /^バックエンド が ([a-zA-Z]+) のコンフィグレータ$/ do | scm |
  @messenger = StringIO.new
  @configurator = Configurator.new( scm, options )
end


Given /^コンフィグレータが Lucie サーバに設定リポジトリ "([^\"]*)" を複製$/ do | url |
  @url = url
  @configurator.clone_to_server @url, "DUMMY_LUCIE_IP"
end


Given /^コンフィグレータがその複製を Lucie クライアント "([^\"]*)" へ配置した$/ do | name |
  @configurator.clone_to_client @url, Nodes.find( name ), "DUMMY_LUCIE_IP"
end


Given /^Lucie サーバ上に ([a-zA-Z]+) で管理された設定リポジトリ \(([^\)]*)\) の複製が存在$/ do | scm, url |
  @scm = scm
  @url = url
end


Given /^Lucie サーバの IP アドレスは "([^\"]*)"$/ do | ip |
  @lucie_ip = ip
end


When /^コンフィグレータが Lucie サーバの更新を実行した$/ do
  @configurator.update_server @url
end


When /^コンフィグレータが Lucie クライアント "([^\"]*)" の更新を実行した$/ do | name |
  @configurator.update_client Nodes.find( name )
end


When /^コンフィグレータがバックエンドのコンフィグレータを Lucie クライアント "([^\"]*)" 上で実行$/ do | name |
  @configurator.start Nodes.find( name )
end


When /^コンフィグレータが Lucie クライアント "([^\"]*)" の SCM を推測$/ do | name |
  @messenger = StringIO.new
  Configurator.guess_scm Nodes.find( name ), options
end


def server_target url
  File.join Configurator::Server.config_directory, Configurator.repository_name_from( url )
end


Then /^Lucie サーバの設定リポジトリが更新される$/ do
  @messenger.string.should match( /^cd #{ regexp_from( server_target( @url ) ) } && hg pull/ )
  @messenger.string.should match( /^cd #{ regexp_from( server_target( @url ) ) } && hg update/ )
end


Then /^Lucie サーバの設定リポジトリ複製が更新される$/ do
  @messenger.string.should match( /^cd #{ regexp_from( server_target( @url ) + ".local" ) } && hg pull/ )
  @messenger.string.should match( /^cd #{ regexp_from( server_target( @url ) + ".local" ) } && hg update/ )
end


def client_target
  File.join Configurator::Client::REPOSITORY_BASE_DIRECTORY, "REPOSITORY_NAME"
end


Then /^Lucie クライアント "([^\"]*)" の設定リポジトリが更新される$/ do | name |
  # 更新でノード -> サーバへパスワード無しで接続するために ssh-agent を使う
  ip = Nodes.find( name ).ip_address
  @messenger.string.should match( /^eval `ssh\-agent`; .* ssh \-A .* root@#{ regexp_from( ip ) } "cd #{ regexp_from client_target } && hg pull/ )
  @messenger.string.should match( /^eval `ssh\-agent`; .* ssh \-A .* root@#{ regexp_from( ip ) } "cd #{ regexp_from client_target } && hg update/ )
end


Then /^Lucie クライアント上のそのリポジトリが "([^\"]*)" コマンドで更新される$/ do | command |
  @messenger.string.should match( regexp_from( command ) )
end


Then /^バックエンドのコンフィグレータが Lucie クライアント "([^\"]*)" 上で実行される$/ do | name |
  ip = Nodes.find( name ).ip_address
  scripts = File.join( client_target, "scripts" )
  ldb = File.join( client_target, "bin", "ldb" )
  @messenger.string.should match( /eval `ssh\-agent`; .* ssh \-A .* root@#{ regexp_from( ip ) } "cd #{ regexp_from( scripts ) } && eval \\`#{ regexp_from( ldb ) } env\\` && make"/ )
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
