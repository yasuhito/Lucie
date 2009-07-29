# -*- coding: utf-8 -*-
Given /^バックエンドとして ([a-z]+) を指定したコンフィグレータ$/ do | scm |
  @messenger = StringIO.new( "" )
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator = Configurator.new( scm.to_sym, options )
end


Given /^コンフィグレータ$/ do
  @messenger = StringIO.new( "" )
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator = Configurator.new( @scm, options )
end


Given /^その SCM がインストールされている$/ do
  @configurator.dpkg = DummyDpkg.new( true )
end


Given /^その SCM がインストールされていない$/ do
  @configurator.dpkg = DummyDpkg.new( false )
end


Given /^設定リポジトリ用ディレクトリがクライアント上に存在しない$/ do
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator.ssh = DummySSH.new( false, options )
end


Given /^設定リポジトリ用ディレクトリがクライアント上にすでに存在$/ do
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator.ssh = DummySSH.new( true, options )
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


When /^コンフィグレータがクライアント \(IP アドレスは "([^\"]*)"\) を初期化した$/ do | ip |
  @ip = ip
  @configurator.setup @ip
end


Then /^設定リポジトリが hg clone コマンドで Lucie サーバに複製される$/ do
  target = Regexp.escape( @url )
  @messenger.string.should match( /^hg clone .+ #{ target } .+/ )
end


Then /^設定リポジトリ用ディレクトリがクライアント上に生成される$/ do
  ip_esc = Regexp.escape( @ip )
  @messenger.string.should match( /^ssh .+ root@#{ ip_esc } "mkdir \-p \/var\/lib\/lucie\/config"$/ )
end


Then /^設定リポジトリ用ディレクトリがクライアント上に生成されない$/ do
  ip_esc = Regexp.escape( @ip )
  @messenger.string.should_not match( /^ssh .+ root@#{ ip_esc } "mkdir \-p \/var\/lib\/lucie\/config"$/ )
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
