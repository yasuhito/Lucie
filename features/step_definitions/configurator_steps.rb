# -*- coding: utf-8 -*-
Given /^バックエンドとして ([a-z]+) を指定したコンフィグレータ$/ do | scm |
  @messenger = StringIO.new( "" )
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator = Configurator.new( scm.to_sym, options )
end


Given /^コンフィグレータ$/ do
  @messenger = StringIO.new( "" )
  @configurator = Configurator.new( @scm, :messenger => @messenger )
end


Given /^その SCM がインストールされている$/ do
  @configurator.dpkg = DummyDpkg.new( true )
end


Given /^その SCM がインストールされていない$/ do
  @configurator.dpkg = DummyDpkg.new( false )
end


Given /^ドライランモードがオン$/ do
  @dry_run = true
end


Given /^冗長モードがオン$/ do
  @verbose = true
end


When /^コンフィグレータが Lucie サーバに設定リポジトリ "([^\"]*)" を複製$/ do | url |
  @url = url
  @configurator.clone @url
end


When /^コンフィグレータが SCM のインストール状況を確認$/ do
  begin
    @configurator.scm_installed?
  rescue
    @error = $!
  end
end


Then /^メッセージ "([^\"]*)"$/ do | message |
  @messenger.string.chomp.should == message
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


Then /^設定リポジトリが hg clone コマンドで Lucie サーバに複製される$/ do
  target = Regexp.escape( @url )
  @messenger.string.should match( /^hg clone .+ #{ target } .+/ )
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
