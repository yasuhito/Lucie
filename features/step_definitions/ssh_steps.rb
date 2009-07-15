Given /^ssh home directory "([^\"]*)" is empty$/ do | path |
  @ssh_home = path
  FileUtils.rm_rf @ssh_home
end


Given /^target directory is "([^\"]*)"$/ do | path |
  @target_directory = path
end


When /^I try to generate ssh keypair$/ do
  @messenger = StringIO.new( "" )
  SSH.generate_keypair( { :ssh_home => @ssh_home, :dry_run => true, :verbose => true }, @messenger )
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


Then /^ssh access to nfsroot configured$/ do
  history.should include( "ssh access to nfsroot configured." )
end

