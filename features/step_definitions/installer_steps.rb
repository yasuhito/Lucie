Given /^installers temporary directory "([^\"]*)" is empty$/ do | dir |
  Configuration.installers_temporary_directory = dir
  FileUtils.rm_rf Dir.glob( File.join( Configuration.installers_temporary_directory, "*" ) )
end


Given /^an installer for suite "([^\"]*)"$/ do | suite |
  @suite = suite
  @messenger = StringIO.new
  installer = Installer.new
  installer.suite = suite
  Installers.add installer, { :verbose => true, :messenger => @messenger }
end


When /^I setup the installer$/ do
  @messenger = StringIO.new
  @verbose = true
  installer_service = Service::Installer.new( debug_options )
  installer_service.setup Installers.load_all.first, "LUCIE_SERVER_IP_ADDRESS"
end


Then /^the installer is built$/ do
  @messenger.string.should match( /Rake\.application\.run/ )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
