# -*- coding: utf-8 -*-
class DummyDpkg
  def initialize installed
    @installed = installed
  end


  def installed? scm
    @installed
  end
end


class DummySSH
  def initialize client_initialized, options
    @ssh = SSH.new( options, options[ :messenger ] )
    @client_initialized = client_initialized
  end


  def cp_r ip, from, to
    @ssh.cp_r ip, from, to
  end


  def sh ip, command
    @ssh.sh ip, command
    if /test \-d/=~ command
      @client_initialized
    end
  end
end


def regexp_from string
  Regexp.escape string
end


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


Given /^Lucie サーバ上に設定リポジトリ \(([^\)]*)\) の複製が存在$/ do | url |
  @url = url
end


Given /^設定リポジトリがクライアント \(IP アドレスは "([^\"]*)"\) 上にすでに存在$/ do | ip |
  @ip = ip
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


When /^コンフィグレータがその設定リポジトリを Lucie クライアント \(IP アドレスは "([^\"]*)"\) へ配置した$/ do | ip |
  @ip = ip
  options = { :dry_run => @dry_run, :verbose => @verbose, :messenger => @messenger }
  @configurator.ssh = DummySSH.new( true, options )
  @configurator.install @ip, @url
end


When /^コンフィグレータが設定プロセスを開始した$/ do
  @configurator.start @ip
end


Then /^設定リポジトリが hg clone コマンドで Lucie サーバに複製される$/ do
  @messenger.string.should match( /^hg clone .+ #{ regexp_from( @url ) } .+/ )
end


Then /^設定リポジトリ用ディレクトリがクライアント上に生成される$/ do
  @messenger.string.should match( /^ssh .+ root@#{ regexp_from( @ip ) } "mkdir \-p \/var\/lib\/lucie\/config"$/ )
end


Then /^設定リポジトリ用ディレクトリがクライアント上に生成されない$/ do
  @messenger.string.should_not match( /^ssh .+ root@#{ regexp_from( @ip ) } "mkdir \-p \/var\/lib\/lucie\/config"$/ )
end


Then /^設定リポジトリが scp \-r コマンドで Lucie クライアントに配置される$/ do
  source = File.join( Configuration.temporary_directory, "ldb", Configurator.convert( @url ) )
  @messenger.string.chomp.should match( /^scp .+ \-r #{ regexp_from( source ) } root@#{ regexp_from( @ip ) }:\/var\/lib\/lucie\/config$/ )
end


Then /^設定ツールが実行される$/ do
  @messenger.string.chomp.should match( /^ssh .+ make"$/ )
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
