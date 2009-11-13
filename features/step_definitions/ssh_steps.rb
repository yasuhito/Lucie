# -*- coding: utf-8 -*-
Given /^ホームディレクトリ "([^\"]*)" に SSH のキーペアがすでに存在$/ do | home |
  @home = home
  FileUtils.rm_rf ssh_home
  touch_ssh_keypair_on ssh_home
end


Given /^ホームディレクトリ "([^\"]*)" に SSH のキーペアが "([^\"]*)"$/ do | home, flag |
  @home = home
  FileUtils.rm_rf ssh_home
  touch_ssh_keypair_on ssh_home if flag == "存在する"
end


Given /^Lucie ディレクトリ "([^\"]*)" に SSH のキーペアが "([^\"]*)"$/ do | lucie_home,  flag |
  @lucie_home = lucie_home
  FileUtils.rm_rf lucie_ssh_home
  touch_ssh_keypair_on lucie_ssh_home if flag == "存在する"
end


Given /^Lucie ディレクトリ "([^\"]*)" に SSH のキーペアが存在しない$/ do | lucie_home |
  @lucie_home = lucie_home
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


When /^SSH のキーペアを生成し、認証しようとした$/ do
  @messenger = StringIO.new( "" )
  SSH.new( debug_options ).maybe_generate_and_authorize_keypair
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
  @messenger = StringIO.new( "" )
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
  File.join @lucie_home, ".ssh"
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
