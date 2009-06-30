Given /^target directory is "([^\"]*)"$/ do | path |
  @target_directory = path
end


When /^I try to setup ssh$/ do
  @messenger = StringIO.new( "" )
  SSH.setup do | ssh |
    ssh.user = "yasuhito"
    ssh.target_directory = @target_directory

    ssh.dry_run = true
    ssh.messenger = @messenger
    ssh.verbose = true
  end
end


Then /^ssh access to nfsroot configured$/ do
  history.should include( "ssh access to nfsroot configured." )
end

