# -*- coding: utf-8 -*-
Given /^バックエンドとして ([a-z]+) を指定したコンフィグレータ$/ do | scm |
  @messenger = StringIO.new( "" )
  @configurator = Configurator.new( scm.to_sym, @messenger )
end


Given /^コンフィグレータ$/ do
  @messenger = StringIO.new( "" )
  @configurator = Configurator.new( @scm, @messenger )
end


Given /^その SCM がインストールされている$/ do
  @configurator.dpkg = DummyDpkg.new( true )
end


Given /^その SCM がインストールされていない$/ do
  @configurator.dpkg = DummyDpkg.new( false )
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


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
