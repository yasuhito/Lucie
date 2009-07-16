When /^I add an installer$/ do
  @messenger = StringIO.new( "" )
  Installers.add Installer.new, { :verbose => @verbose, :dry_run => @dry_run }, @messenger
end


Then /^temporary directory for the installer created$/ do
  dir = File.join( Configuration.installers_temporary_directory, "#{ @suite }_i386" )
  history.should include( "mkdir -p #{ dir }" )
end


Then /^installer configuration file for "([^\"]*)" generated$/ do | suite |
  config = File.join( Configuration.installers_temporary_directory, "#{ suite }_i386", "config.rb" )
  history.should include( "file write (#{ config })" )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
