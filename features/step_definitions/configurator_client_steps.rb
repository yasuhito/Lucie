# -*- coding: utf-8 -*-
class DummySSH
  def initialize client_initialized, options
    @ssh = SSH.new( options, options[ :messenger ] )
    @client_initialized = client_initialized
  end


  def cp ip, from, to
    @ssh.cp ip, from, to
  end


  def sh ip, command
    @ssh.sh ip, command
    if /test \-d/=~ command
      raise "test -d failed" unless @client_initialized
    end
  end


  def sh_a ip, command
    @ssh.sh_a ip, command
  end
end


Given /^クライアントコンフィグレータ$/ do
  @messenger = StringIO.new
  @configurator = Configurator::Client.new( @scm, options )
end


Given /^config ディレクトリが Lucie クライアント上にすでに存在$/ do
  @configurator.ssh = DummySSH.new( true, options )
end


Given /^bin ディレクトリが Lucie クライアント上にすでに存在$/ do
  @configurator.ssh = DummySSH.new( true, options )
end


Given /^config ディレクトリが Lucie クライアント上に存在しない$/ do
  @configurator.ssh = DummySSH.new( false, options )
end


Given /^bin ディレクトリが Lucie クライアント上に存在しない$/ do
  @configurator.ssh = DummySSH.new( false, options )
end


Given /^設定リポジトリがクライアント \(IP アドレスは "([^\"]*)"\) 上にすでに存在$/ do | ip |
  @ip = ip
  @messenger = StringIO.new
  @configurator = Configurator::Client.new( :mercurial, options )
  @configurator.install "DUMMY_SERVER_IP", @ip, "DUMMY_REPOSITORY_URL"
end


When /^クライアントコンフィグレータが Lucie クライアント \(IP アドレスは "([^\"]*)"\) を初期化した$/ do | ip |
  @ip = ip
  @configurator.setup @ip
end


When /^クライアントコンフィグレータがその設定リポジトリを Lucie クライアント \(IP アドレスは "([^\"]*)"\) へ配置した$/ do | ip |
  @ip = ip
  @messenger = StringIO.new

  @configurator = Configurator::Client.new( @scm, options )
  @configurator.ssh = DummySSH.new( true, options )
  @configurator.install @lucie_ip, @ip, @url
end


When /^クライアントコンフィグレータが設定プロセスを開始した$/ do
  @configurator.start @ip
end


When /^クライアントコンフィグレータがその Lucie クライアント上のリポジトリを更新した$/ do
  @configurator.update @ip, @lucie_ip, Configurator::Server.clone_directory( @url )
end


Then /^config ディレクトリが Lucie クライアント上に生成される$/ do
  @messenger.string.should match( /ssh .+ root@#{ regexp_from( @ip ) } "mkdir \-p \/var\/lib\/lucie\/config"/ )
end


Then /^bin ディレクトリが Lucie クライアント上に生成される$/ do
  @messenger.string.should match( /ssh .+ root@#{ regexp_from( @ip ) } "mkdir \-p \/var\/lib\/lucie\/bin"/ )
end


Then /^config ディレクトリが Lucie クライアント上に生成されない$/ do
  @messenger.string.should_not match( /^ssh .+ root@#{ regexp_from( @ip ) } "mkdir \-p \/var\/lib\/lucie\/config"$/ )
end


Then /^bin ディレクトリが Lucie クライアント上に生成されない$/ do
  @messenger.string.should_not match( /^ssh .+ root@#{ regexp_from( @ip ) } "mkdir \-p \/var\/lib\/lucie\/bin"$/ )
end


Then /^設定リポジトリが (.+) コマンドで Lucie クライアントに配置される$/ do | command |
  @messenger.string.split( "\n" ).last.should match( /#{ regexp_from( command ) }/ )
end


Then /^設定ツールが実行される$/ do
  @messenger.string.split( "\n" ).last.should match( /make/ )
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
