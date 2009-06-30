Given /^\-\-address option is "([^\"]*)"$/ do | value |
  @address = [ "--address=#{ value }" ]
end


Given /^\-\-netmask option is "([^\"]*)"$/ do | value |
  @netmask = [ "--netmask=#{ value }" ]
end


Given /^\-\-mac option is "([^\"]*)"$/ do | value |
  @mac = [ "--mac=#{ value }" ]
end


Given /^\-\-storage\-conf option is "([^\"]*)"$/ do | value |
  @storage_conf = [ "--storage-conf=#{ value }" ]
end


When /^I run node install "([^\"]*)"$/ do | node |
  pending
  verbose = @verbose ? [ "--verbose" ] : []
  dry_run = @dry_run ? [ "--dry-run" ] : []
  opts = [ "--reboot-script=true" ] + @address + @netmask + @mac + @storage_conf + verbose + dry_run
  @messenger = StringIO.new( "" )
  Command::NodeInstall::App.new( opts, @messenger, [ @if ] ).main( [ node ] )
end


Then /^node "([^\"]*)" installed$/ do | node |
  history.should include( "Node '#{ node }' installed." )
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
