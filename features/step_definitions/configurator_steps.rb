# -*- coding: utf-8 -*-
Given /^SCM として ([a-z]+) を選択$/ do | scm |
  @scm = scm.to_sym
end


Given /^コンフィグレータ$/ do
  @messenger = StringIO.new( "" )
  @configurator = Configurator.new( @scm, @messenger )
end


Given /^SCM がインストールされている$/ do
  @configurator.dpkg = DummyDpkg.new( true )
end


When /^コンフィグレータが SCM を確認$/ do
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


Given /^SCM がインストールされていない$/ do
  @configurator.dpkg = DummyDpkg.new( false )
end


Then /^エラー "([^\"]*)"$/ do | message |
  @error.should_not be_nil
  @error.message.should == message
end
