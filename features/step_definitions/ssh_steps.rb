# -*- coding: utf-8 -*-
Given /^ホームディレクトリ "([^\"]*)" に SSH のキーペアがすでに存在$/ do | home |
  @home = home
  ssh_home = File.join( @home, ".ssh" )
  FileUtils.rm_rf ssh_home
  FileUtils.mkdir_p ssh_home
  FileUtils.touch File.join( ssh_home, "id_rsa" )
  FileUtils.touch File.join( ssh_home, "id_rsa.pub" )
end


Given /^Lucie ディレクトリ "([^\"]*)" に SSH のキーペアがすでに存在$/ do | lucie_home |
  @lucie_home = lucie_home
  lucie_ssh_home = File.join( @lucie_home, ".ssh" )
  FileUtils.rm_rf lucie_ssh_home
  FileUtils.mkdir_p lucie_ssh_home
  FileUtils.touch File.join( lucie_ssh_home, "id_rsa" )
  FileUtils.touch File.join( lucie_ssh_home, "id_rsa.pub" )
end


Given /^ホームディレクトリ "([^\"]*)" に SSH のキーペアが存在しない$/ do | home |
  @home = home
  ssh_home = File.join( home, ".ssh" )
  FileUtils.rm_rf ssh_home
  FileUtils.mkdir_p ssh_home
end


Given /^Lucie ディレクトリ "([^\"]*)" に SSH のキーペアが存在しない$/ do | lucie_home |
  @lucie_home = lucie_home
  lucie_ssh_home = File.join( @lucie_home, ".ssh" )
  FileUtils.rm_rf lucie_ssh_home
  FileUtils.mkdir_p lucie_ssh_home
end


Given /^authorized_keys が存在しない$/ do
  FileUtils.rm_f File.join( @home, ".ssh", "authorized_keys" )
end


Given /^空の authorized_keys が存在$/ do
  FileUtils.mkdir_p File.join( @home, ".ssh" )
  FileUtils.rm_f File.join( @home, ".ssh", "authorized_keys" )
  FileUtils.touch File.join( @home, ".ssh", "authorized_keys" )
end


When /^SSH のキーペアを生成しようとした$/ do
  @messenger = StringIO.new( "" )
  SSH.new( debug_options ).generate_keypair
end


Then /^SSH のキーペアは生成されない$/ do
  history.join( "\n" ).should_not match( /^ssh\-keygen/ )
end


Then /^ホームディレクトリ以下に SSH のキーペアが生成される$/ do
  private_key = File.join( @home, ".ssh", "id_rsa" )
  history.should include( %{ssh-keygen -t rsa -N "" -f #{ private_key }} )
end


Then /^公開鍵が authorized_keys にコピーされる$/ do
  public_key = File.join( @home, ".ssh", "id_rsa.pub" )
  authorized_keys = File.expand_path( File.join( "~", ".ssh", "authorized_keys" ) )
  history.should include( "cat #{ public_key } >> #{ authorized_keys }" )
end


Then /^公開鍵が authorized_keys に追加される$/ do
  Then "公開鍵が authorized_keys にコピーされる"
end


Given /^nfsroot directory is "([^\"]*)"$/ do | path |
  @target_directory = path
  FileUtils.rm_rf @target_directory
end


When /^I try to setup ssh$/ do
  @messenger = StringIO.new( "" )
  ssh = SSH.new( :dry_run => true, :verbose => true, :messenger => @messenger )
  ssh.setup_nfsroot @target_directory
end


Then /^ssh access to nfsroot configured$/ do
  history.should include( "ssh access to nfsroot configured." )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
