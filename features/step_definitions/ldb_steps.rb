# -*- coding: utf-8 -*-
Given /^LDB が Lucie サーバに設定リポジトリ "([^\"]*)" を複製$/ do | url |
  @url = url
  @messenger = StringIO.new( "" )
  @ldb = LDB.new( { :dry_run => @dry_run, :verbose => @verbose }, @messenger )
  @ldb.clone_to_server @url, "DUMMY_LUCIE_IP"
end


Given /^LDB がその複製を Lucie クライアント "([^\"]*)" へ配置した$/ do | name |
  @ldb.clone_to_client @url, Nodes.find( name ), "DUMMY_LUCIE_IP"
end


Given /^remote hg repository "([^\"]*)"$/ do | url |
  @hg_url = url
end


Given /^local repository is empty$/ do
  FileUtils.rm_rf Dir.glob( File.join( Configuration.temporary_directory, "*" ) )
end


Given /^local hg repository already exists$/ do
  FileUtils.mkdir_p File.join( Configuration.temporary_directory, "ldb", "DUMMY_LDB_DIRECTORY" )
  FileUtils.mkdir_p File.join( Configuration.temporary_directory, "ldb", "DUMMY_LDB_DIRECTORY.local" )
end


Given /^the hg repository already cloned to "([^\"]*)"$/ do | name |
end


When /^LDB がクライアント "([^\"]*)" の更新を実行した$/ do | name |
  @ldb.update Nodes.find( name )
end


When /^I update LDB on node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  logger = Lucie::Logger::Installer.new( "/tmp", true )
  @ldb = LDB.new( { :dry_run => true, :verbose => true }, @messenger, [ @if ] )
  @ldb.update Nodes.find( name ), logger
end


When /^I clone remote repository$/ do
  @messenger = StringIO.new( "" )
  logger = Lucie::Logger::Installer.new( "/tmp", true )
  @ldb = LDB.new( { :dry_run => true, :verbose => true }, @messenger, [ @if ] )
  @ldb.clone @hg_url, @if.ip_address, logger
end


When /^I start LDB on node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  logger = Lucie::Logger::Installer.new( "/tmp", true )
  @ldb = LDB.new( { :dry_run => true, :verbose => true }, @messenger, [ @if ] )
  @ldb.start Nodes.find( name ), logger
end


Then /^ldb installed on "([^\"]*)"$/ do | url |
  name, path = url.split( ':' )
  @messenger.string.should match( /hg clone/ )
  history.should include( "ldb installed on node #{ name }." )
  show_history
end


Then /^LDB on "([^\"]*)" updated$/ do | name |
  history.should include( "LDB updated on node #{ name }." )
end


Then /^repository cloned to local$/ do
  history.should include( "LDB #{ @hg_url } cloned to local." )
end


Then /^local repository updated$/ do
  history.should include( "clone and clone-clone LDB repositories on local updated." )
end


Then /^configurations updated on "([^\"]*)"$/ do | name |
  history.should include( "LDB executed on #{ name }." )
  @messenger.string.should match( /make/ )
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


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
