Given /^installers directory "([^\"]*)" is empty$/ do | dir |
  Configuration.installers_directory = dir
  FileUtils.rm_rf Dir.glob( File.join( Configuration.installers_directory, "*" ) )
end


Given /^installers temporary directory "([^\"]*)" is empty$/ do | dir |
  Configuration.installers_temporary_directory = dir
  FileUtils.rm_rf Dir.glob( File.join( Configuration.installers_temporary_directory, "*" ) )
end


Given /^an installer for suite "([^\"]*)"$/ do | suite |
  @suite = suite
  @messenger = StringIO.new( "" )
  installer = Installer.new
  installer.suite = suite
  Installers.add installer, { :verbose => true }, @messenger
end


Given /^an installer for suite "([^\"]*)" added and built$/ do | suite |
  @messenger = StringIO.new( "" )
  installer = Installer.new
  installer.suite = suite
  Installers.add installer, { :verbose => true }, @messenger
  installer.build @if, { :verbose => true, :dry_run => true }, @messenger
end


When /^I setup installer$/ do
  @messenger = StringIO.new( "" )
  @verbose = true
  installer_service = Service::Installer.new( debug_options )
  installer_service.setup Nodes.load_all, Installers.load_all.first
end


Then /^installer built$/ do
  history.should include( "Setting up installer ..." )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
