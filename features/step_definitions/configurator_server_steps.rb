# -*- coding: utf-8 -*-
class DummyDpkg
  def initialize installed
    @installed = installed
  end


  def installed? scm
    @installed
  end
end


Given /^バックエンドとして ([a-z]+) を指定したサーバーコンフィグレータ$/ do | scm |
  @scm = scm.to_sym
  @messenger = StringIO.new( "" )
  @configurator = Configurator::Server.new( @scm, options )
end


Given /^バックエンドの SCM が指定されていないサーバーコンフィグレータ$/ do
  @messenger = StringIO.new( "" )
  @configurator = Configurator::Server.new( @scm, options )
end


Given /^その SCM がインストールされている$/ do
  @configurator.dpkg = DummyDpkg.new( true )
end


Given /^その SCM がインストールされていない$/ do
  @configurator.dpkg = DummyDpkg.new( false )
end


Given /^設定リポジトリ用ディレクトリが Lucie サーバ上に存在しない$/ do
  FileUtils.rm_rf Configuration.temporary_directory
end


Given /^設定リポジトリ用ディレクトリが Lucie サーバ上にすでに存在$/ do
  FileUtils.mkdir_p Configuration.temporary_directory
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
    @configurator.check_backend_scm
  rescue
    @error = $!
  end
end


When /^サーバーコンフィグレータが Lucie サーバにその設定リポジトリのローカル複製を作成$/ do
  @configurator.clone_clone @url, "DUMMY_SERVER_IP"
end


When /^サーバーコンフィグレータが Lucie サーバを初期化した$/ do
  @messenger = StringIO.new( "" )
  configurator = Configurator::Server.new( nil, options )
  configurator.setup
end


When /^サーバーコンフィグレータがその設定リポジトリを更新した$/ do
  @configurator.update @url
end


Then /^"([^\"]*)" コマンドでローカルな設定リポジトリの複製が作成される$/ do | command |
  from = File.join( Configurator::Server.config_directory, Configurator.convert( @url ) )
  to = from + ".local"
  @messenger.string.split( "\n" ).last.should match( /^#{ regexp_from( command ) }.*#{ regexp_from( from ) } #{ regexp_from( to ) }$/ )
end


Then /^設定リポジトリ用ディレクトリが Lucie サーバ上に生成される$/ do
  @messenger.string.chomp.should == "mkdir -p #{ Configuration.temporary_directory }"
end


Then /^設定リポジトリ用ディレクトリが Lucie サーバ上に生成されない$/ do
  @messenger.string.should be_empty
end


Then /^その設定リポジトリが "([^\"]*)" コマンドで更新される$/ do | command |
  @messenger.string.split( "\n" ).last.should match( regexp_from( command ) )
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
