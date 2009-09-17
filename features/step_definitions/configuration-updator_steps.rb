# -*- coding: utf-8 -*-
def server_target
  File.join Configurator::Server.config_directory, @repository_name
end


Given /^Lucie クライアント "([^\"]*)" 用の設定リポジトリ \(([a-zA-Z]+)\)$/ do | name, scm |
  Given %{Lucie クライアント "#{ name }"}
  @scm = Scm.from( scm )
end


Given /^コンフィグレータがその設定リポジトリを Lucie サーバに複製$/ do
  @repository_name = "REPOSITORY"
  FileUtils.mkdir_p server_target
end


Given /^その設定リポジトリが Lucie サーバ上に複製されていない$/ do
  @repository_name = "REPOSITORY"
  FileUtils.rm_rf server_target
end


Given /^コンフィグレータがその設定リポジトリを Lucie サーバ上でローカルに複製$/ do
  # [???] ここでは何もしない？
end


Given /^コンフィグレータがその設定リポジトリを Lucie クライアント "([^\"]*)" に複製$/ do | name |
  @repository_name = "CLIENT_REPOSITORY"
end


Given /^コンフィグレータがその設定リポジトリを Lucie クライアント "([^\"]*)" に複製していない$/ do | name |
  @repository_name = nil
end


Given /^([a-zA-Z]+) が Lucie サーバにインストールされている$/ do | scm |
  @custom_dpkg = SuccessfulDpkg.new
end


Given /^([a-zA-Z]+) が Lucie サーバにインストールされていない$/ do | scm |
  @custom_dpkg = FailingDpkg.new
end


Given /^([a-zA-Z]+) が Lucie クライアントにインストールされている$/ do | scm |
  @custom_dpkg = SuccessfulDpkg.new
end


Given /^([a-zA-Z]+) が Lucie クライアントにインストールされていない$/ do | scm |
  @custom_dpkg = FailingDpkg.new
end


class DummySCM
  def test_installed
    true
  end


  def update path
    raise "Failed with ERROR_CODE = 12345"
  end
end


Given /^([a-zA-Z]+) が壊れている$/ do | scm |
  @dummy_scm =DummySCM.new
end


When /^コンフィグレーションアップデータが Lucie サーバの更新を実行 \(ノードに "([^\"]*)" を指定\)$/ do | name |
  begin
    @messenger = StringIO.new
    @updator = ConfigurationUpdator.new( debug_options )
    @updator.update_server_for [ Nodes.find( name ) ]
  rescue
    @error = $!
  end
end


When /^コンフィグレーションアップデータが Lucie クライアント "([^\"]*)" の更新を実行$/ do | name |
  begin
    @messenger = StringIO.new
    @updator = ConfigurationUpdator.new( debug_options )
    @updator.update_client Nodes.find( name )
  rescue
    @error = $!
  end
end


Then /^Lucie サーバの設定リポジトリが "([^\"]*)" コマンドで更新される$/ do | command |
  command.split( /,\s*/ ).each do | each |
    @messenger.string.should match( /^cd #{ regexp_from server_target } && #{ each }/ )
  end
end


Then /^Lucie クライアント上のそのリポジトリが "([^\"]*)" コマンドで更新される$/ do | command |
  command.split( /,\s*/ ).each do | each |
    @messenger.string.should match( regexp_from each )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
