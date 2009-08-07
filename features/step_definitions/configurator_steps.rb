# -*- coding: utf-8 -*-
Given /^コンフィグレータが Lucie サーバに設定リポジトリ "([^\"]*)" を複製$/ do | url |
  @url = url
  @messenger = StringIO.new( "" )
  @configurator = Configurator.new( options )
  @configurator.clone_to_server @url, "DUMMY_LUCIE_IP"
end


Given /^コンフィグレータがその複製を Lucie クライアント "([^\"]*)" へ配置した$/ do | name |
  @configurator.clone_to_client @url, Nodes.find( name ), "DUMMY_LUCIE_IP"
end


Given /^Lucie サーバ上に ([a-z]+) で管理された設定リポジトリ \(([^\)]*)\) の複製が存在$/ do | scm, url |
  @scm = scm.to_sym
  @url = url
end


Given /^設定リポジトリがクライアント \(IP アドレスは "([^\"]*)"\) 上にすでに存在$/ do | ip |
  @ip = ip
  @messenger = StringIO.new( "" )
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator = Configurator::Client.new( :mercurial, options )
  @configurator.install "DUMMY_SERVER_IP", @ip, "DUMMY_REPOSITORY_URL"
end


Given /^Lucie サーバの IP アドレスは "([^\"]*)"$/ do | ip |
  @lucie_ip = ip
end


Given /^ドライランモードがオン$/ do
  @dry_run = true
end


Given /^冗長モードがオン$/ do
  @verbose = true
end


Given /^Lucie のテンポラリディレクトリは "([^\"]*)"$/ do | path |
  Configuration.temporary_directory = path
end


Given /^コンフィグレータがその設定リポジトリを Lucie クライアント "([^\"]*)" へ配置した$/ do | name |
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator = Configurator::Client.new( @scm, options )
  @configurator.install @lucie_ip, name, @url
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


def server_target url
  File.join Configurator::Server.config_directory, Configurator.convert( url )
end


Then /^Lucie サーバの設定リポジトリが更新される$/ do
  @messenger.string.should match( /^cd #{ regexp_from( server_target( @url ) ) } && hg pull/ )
  @messenger.string.should match( /^cd #{ regexp_from( server_target( @url ) ) } && hg update/ )
end


Then /^Lucie サーバの設定リポジトリ複製が更新される$/ do
  @messenger.string.should match( /^cd #{ regexp_from( server_target( @url ) + ".local" ) } && hg pull/ )
  @messenger.string.should match( /^cd #{ regexp_from( server_target( @url ) + ".local" ) } && hg update/ )
end


def client_target url
  File.join Configurator::Client::REPOSITORY_BASE_DIRECTORY, Configurator.convert( url )
end


Then /^Lucie クライアント "([^\"]*)" の設定リポジトリが更新される$/ do | name |
  # 更新でノード -> サーバへパスワード無しで接続するために ssh-agent を使う
  ip = Nodes.find( name ).ip_address
  @messenger.string.should match( /^eval `ssh\-agent`; .* ssh \-A .* root@#{ regexp_from( ip ) } "cd #{ regexp_from( client_target( @url ) ) } && hg pull/ )
  @messenger.string.should match( /^eval `ssh\-agent`; .* ssh \-A .* root@#{ regexp_from( ip ) } "cd #{ regexp_from( client_target( @url ) ) } && hg update/ )
end


Then /^"([^\"]*)" コマンドで設定リポジトリが Lucie サーバに複製される$/ do | command |
  @messenger.string.should match( /^#{ regexp_from( command ) }.*#{ regexp_from( @url ) }.*#{ regexp_from( Configurator.convert( @url ) ) }.*/ )
end


Then /^Lucie クライアント上のそのリポジトリが "([^\"]*)" コマンドで更新される$/ do | command |
  @messenger.string.should match( regexp_from( command ) )
end


Then /^メッセージは空$/ do
  @messenger.string.should == ""
end


Then /^エラーが発生しない$/ do
  @error.should be_nil
end


Then /^エラー "([^\"]*)"$/ do | message |
  @error.should_not be_nil
  @error.message.should == message
end


Then /^バックエンドのコンフィグレータが Lucie クライアント "([^\"]*)" 上で実行される$/ do | name |
  ip = Nodes.find( name ).ip_address
  scripts = File.join( client_target( @url ), "scripts" )
  ldb = File.join( client_target( @url ), "bin", "ldb" )
  @messenger.string.should match( /eval `ssh\-agent`; .* ssh \-A .* root@#{ regexp_from( ip ) } "cd #{ regexp_from( scripts ) } && eval `#{ regexp_from( ldb ) } env` && make"/ )
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
