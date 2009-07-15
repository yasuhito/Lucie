Given /^ssh home directory "([^\"]*)" is empty$/ do | path |
  @ssh_home = path
  FileUtils.rm_rf @ssh_home
  FileUtils.mkdir_p @ssh_home
end


Given /^ssh keypair already generated$/ do
  FileUtils.mkdir_p @ssh_home unless FileTest.directory?( @ssh_home )
  FileUtils.touch File.join( @ssh_home, "id_rsa" )
  FileUtils.touch File.join( @ssh_home, "id_rsa.pub" )
end


Given /^authorized_keys does not exist$/ do
  FileUtils.rm_f File.join( @ssh_home, "authorized_keys" )
end


Given /^empty authorized_keys already exists$/ do
  FileUtils.rm_f File.join( @ssh_home, "authorized_keys" )
  FileUtils.touch File.join( @ssh_home, "authorized_keys" )
end


Given /^nfsroot directory is "([^\"]*)"$/ do | path |
  @target_directory = path
  FileUtils.rm_rf @target_directory
end


When /^I try to generate ssh keypair$/ do
  @messenger = StringIO.new( "" )
  SSH.generate_keypair( { :ssh_home => @ssh_home, :verbose => true }, @messenger )
end


When /^I try to setup ssh$/ do
  @messenger = StringIO.new( "" )
  SSH.setup_nfsroot do | ssh |
    ssh.target_directory = @target_directory
    ssh.dry_run = true
    ssh.messenger = @messenger
    ssh.verbose = true
  end
end


Then /^ssh keypair generated$/ do
  private_key = File.join( @ssh_home, "id_rsa" )
  history.should include( %{ssh-keygen -t rsa -N "" -f #{ private_key }} )
end


Then /^ssh keypair not generated$/ do
  private_key = File.join( @ssh_home, "id_rsa" )
  history.should_not include( %{ssh-keygen -t rsa -N "" -f #{ private_key }} )
end


Then /^ssh access to nfsroot configured$/ do
  history.should include( "ssh access to nfsroot configured." )
end


Then /^generated public key copied to authorized_keys$/ do
  public_key = File.join( @ssh_home, "id_rsa.pub" )
  authorized_keys = File.join( @ssh_home, "authorized_keys" )
  history.should include( "cp #{ public_key } #{ authorized_keys }" )
end


Then /^generated public key appended to authorized_keys$/ do
  public_key = File.join( @ssh_home, "id_rsa.pub" )
  authorized_keys = File.join( @ssh_home, "authorized_keys" )
  history.should include( "cat #{ public_key } >> #{ authorized_keys }" )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
