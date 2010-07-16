# -*- coding: utf-8 -*-
Given /^ホームディレクトリは "([^\"]*)"$/ do | home |
  @home = home
end


Given /^ホームディレクトリに SSH のキーペアがすでに存在$/ do
  FileUtils.rm_rf ssh_home
  touch_ssh_keypair_on ssh_home
end


Given /^ホームディレクトリに SSH のキーペアが "([^\"]*)"$/ do | flag |
  FileUtils.rm_rf ssh_home
  touch_ssh_keypair_on ssh_home if flag == "存在する"
end


Given /^ホームディレクトリに Lucie 用の SSH キーペアが "([^\"]*)"$/ do | flag |
  FileUtils.rm_rf lucie_ssh_home
  touch_ssh_keypair_on lucie_ssh_home if flag == "存在する"
end


Given /^ホームディレクトリに Lucie 用の SSH キーペアが存在しない$/ do
  FileUtils.rm_rf lucie_ssh_home
end


Given /^authorized_keys が存在しない$/ do
  FileUtils.rm_f authorized_keys
end


Given /^空の authorized_keys が存在$/ do
  FileUtils.mkdir_p ssh_home
  FileUtils.rm_f authorized_keys
  FileUtils.touch authorized_keys
end


When /^SSH でノード "([^\"]*)" にコマンド "([^\"]*)" を実行$/ do | node, command |
  @messenger = StringIO.new
  @verbose = true
  SSH.new( debug_options ).sh( node, command )
end


When /^SSH \-A でノード "([^\"]*)" にコマンド "([^\"]*)" を実行$/ do | node, command |
  @messenger = StringIO.new
  @verbose = true
  SSH.new( debug_options ).sh_a( node, command )
end


When /^ファイル "([^\"]*)" をノード "([^\"]*)" の "([^\"]*)" に SCP でコピー$/ do | from, node, dir |
  @messenger = StringIO.new
  @verbose = true
  SSH.new( debug_options ).cp( from, "#{ node }:#{ dir }" )
end


When /^ディレクトリ "([^\"]*)" をノード "([^\"]*)" の "([^\"]*)" に SCP \-r でコピー$/ do | from, node, dir |
  @messenger = StringIO.new
  @verbose = true
  SSH.new( debug_options ).cp_r( from, "#{ node }:#{ dir }" )
end


When /^SSH のキーペアを生成し、認証しようとした$/ do
  @messenger = StringIO.new
  @verbose = true
  SSH.new( debug_options ).maybe_generate_keypair
end


Then /^ノード "([^\"]*)" 上でコマンド "([^\"]*)" が root 権限で実行される$/ do | node, command |
  @messenger.string.should match( /^ssh .* root@#{ node } "#{ command }"$/ )
end


Then /^エージェントフォワーディングを有効にした上で、ノード "([^\"]*)" 上でコマンド "([^\"]*)" が root 権限で実行される$/ do | node, command |
  @messenger.string.should match( /^eval `ssh\-agent`; ssh\-add .*; ssh \-A .* root@#{ node } "#{ command }"$/ )
end


Then /^ファイル "([^\"]*)" がノード "([^\"]*)" の "([^\"]*)" に SCP でコピーされる$/ do | from, node, to |
  @messenger.string.should match( /^scp .* #{ Regexp.escape from } #{ node }:#{ Regexp.escape to }$/ )
end


Then /^ディレクトリ "([^\"]*)" がノード "([^\"]*)" の "([^\"]*)" に SCP \-r でコピーされる$/ do | from, node, to |
  @messenger.string.should match( /^scp .* \-r #{ Regexp.escape from } #{ node }:#{ Regexp.escape to }$/ )
end


Then /^SSH のキーペアは "([^\"]*)"$/ do | flag |
  if flag == "生成される"
    history.should include( %{ssh-keygen -t rsa -N "" -f #{ private_key }} )
  else
    history.join( "\n" ).should_not match( /^ssh\-keygen/ )
  end
end


Then /^ホームディレクトリの公開鍵が authorized_keys にコピーされる$/ do
  history.should include( "cat #{ public_key } >> #{ authorized_keys }" )
end


Then /^ホームディレクトリの公開鍵が authorized_keys に追加される$/ do
  Then "ホームディレクトリの公開鍵が authorized_keys にコピーされる"
end


Given /^nfsroot のパスは "([^\"]*)"$/ do | path |
  @nfsroot_directory = path
  FileUtils.rm_rf @nfsroot_directory
  FileUtils.mkdir_p @nfsroot_directory
end


When /^nfsroot に SSH の鍵を仕込もうとした$/ do
  @messenger = StringIO.new
  SSH.new( debug_options ).setup_ssh_access_to @nfsroot_directory
end


Then /^nfsroot への SSH ログインができるようになる$/ do
  history.should include( "ssh access to nfsroot configured." )
end


################################################################################
# Utils
################################################################################


def touch_ssh_keypair_on base_dir
  FileUtils.mkdir_p base_dir
  FileUtils.touch File.join( base_dir, "id_rsa" )
  FileUtils.touch File.join( base_dir, "id_rsa.pub" )
end


def ssh_home
  File.join @home, ".ssh"
end


def lucie_ssh_home
  File.join @home, ".lucie"
end


def public_key
  File.join @home, ".ssh", "id_rsa.pub"
end


def private_key
  File.join @home, ".ssh", "id_rsa"
end


def authorized_keys
  File.join @home, ".ssh", "authorized_keys"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
