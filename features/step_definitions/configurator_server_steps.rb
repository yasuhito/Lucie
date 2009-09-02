# -*- coding: utf-8 -*-
Given /^バックエンドとして ([a-zA-Z]+) を指定したサーバーコンフィグレータ$/ do | scm |
  @messenger = StringIO.new
  @configurator = Configurator::Server.new( scm, options )
end


Given /^バックエンドの SCM が指定されていないサーバーコンフィグレータ$/ do
  @messenger = StringIO.new
  @configurator = Configurator::Server.new( nil, options )
end


Given /^([a-zA-Z]+) がインストールされている$/ do | scm |
  @custom_dpkg = SuccessfulDpkg.new
end


Given /^([a-zA-Z]+) がインストールされていない$/ do | scm |
  @custom_dpkg = FailingDpkg.new
end


Given /^設定リポジトリ用ディレクトリが Lucie サーバ上に存在しない$/ do
  FileUtils.rm_rf Configurator::Server.config_directory
end


Given /^設定リポジトリ用ディレクトリが Lucie サーバ上にすでに存在$/ do
  FileUtils.mkdir_p Configurator::Server.config_directory
end


When /^サーバーコンフィグレータが Lucie サーバに設定リポジトリ "([^\"]*)" を複製$/ do | url |
  @url = url
  begin
    @configurator.clone @url
  rescue
    @error = $!
  end
end


When /^サーバーコンフィグレータが SCM のインストール状況を確認$/ do
  begin
    @configurator.__send__ :check_scm
  rescue
    @error = $!
  end
end


When /^サーバーコンフィグレータが Lucie サーバにその設定リポジトリのローカル複製を作成$/ do
  begin
    @configurator.clone_clone @url, "DUMMY_SERVER_IP"
  rescue
    @error = $!
  end
end


When /^サーバーコンフィグレータがその設定リポジトリを更新した$/ do
  @configurator.update Configurator.repository_name_from( @url )
end


Then /^"([^\"]*)" コマンドでローカルな設定リポジトリの複製が作成される$/ do | command |
  source = regexp_from( Configurator::Server.clone_directory( @url ) )
  dest = regexp_from( Configurator::Server.clone_directory( @url ) + ".local" )
  @messenger.string.split( "\n" ).last.should match( /^#{ regexp_from( command ) }.*#{ source } #{ dest }$/ )
end


Then /^設定リポジトリ用ディレクトリが Lucie サーバ上に生成される$/ do
  history.should include( "mkdir -p #{ Configurator::Server.config_directory }" )
end


Then /^設定リポジトリ用ディレクトリが Lucie サーバ上に生成されない$/ do
  history.should_not include( "mkdir -p #{ Configurator::Server.config_directory }" )
end


Then /^その設定リポジトリが "([^\"]*)" コマンドで更新される$/ do | command |
  clone = regexp_from( Configurator::Server.clone_directory( @url ) )
  command.split( /,\s*/ ).each do | each |
    @messenger.string.should match( /^cd #{ clone } && #{ regexp_from( each ) }/ )
  end
end


Then /^その設定リポジトリのローカル複製が "([^\"]*)" コマンドで更新される$/ do | command |
  clone_clone = regexp_from( Configurator::Server.clone_directory( @url ) + ".local" )
  command.split( /,\s*/ ).each do | each |
    @messenger.string.should match( /^cd #{ clone_clone } && #{ regexp_from( each ) }/ )
  end
end


Then /^"([^\"]*)" コマンドで設定リポジトリが Lucie サーバに複製される$/ do | command |
  source = regexp_from( @url )
  dest = regexp_from( Configurator::Server.clone_directory( @url ) )
  @messenger.string.should match( /^#{ regexp_from( command ) }.*#{ source } #{ dest }$/ )
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
