# -*- coding: utf-8 -*-

################################################################################
# Misc.
################################################################################


Given /^the rake task list cleared$/ do
  Rake::Task.clear
end


Given /^eth0 "(.*)"$/ do | ip |
  @if = DummyInterface.new( ip, "255.255.255.0", Network.network_address( ip, "255.255.255.0" ) )
end


################################################################################
# Lucie paths
################################################################################


Given /^Lucie log path is "([^\"]*)"$/ do | path |
  FileUtils.mkdir_p File.dirname( path )
  Lucie::Log.path = path
end


Given /^Lucie のテンポラリディレクトリは "([^\"]*)"$/ do | path |
  Configuration.temporary_directory = path
  FileUtils.rm_rf Dir.glob( File.join( Configuration.temporary_directory, "*" ) )
end


Given /^installers temporary directory is "([^\"]*)"$/ do | path |
  Configuration.installers_temporary_directory = path
  FileUtils.rm_rf Dir.glob( File.join( Configuration.installers_temporary_directory, "*" ) )
end


################################################################################
# File/Directory existance
################################################################################


Given /^a file "([^\"]*)" not exist$/ do | name |
  system "rm -f #{ name }"
end


Given /^a directory "([^\"]*)" not exist$/ do | name |
  system "rm -rf #{ name }"
end


################################################################################
# On/Off --verbose option
################################################################################


Given /^\-\-verbose option is on$/ do
  @verbose = true
end


Given /^\-\-verbose option is off$/ do
  @verbose = false
end


################################################################################
# Messages
################################################################################


Then /^"(.*)" displayed$/ do | line |
  history.should include( line )
end


Then /^nothing displayed$/ do
  history.should be_empty
end


Then /^次の出力を得る:$/ do | string |
  @messenger.string.chomp.should == string.chomp
end


################################################################################
# Errors
################################################################################


Then /^nothing raised$/ do
  @error.should be_nil
end


Then /^エラーが発生しない$/ do
  Then "nothing raised"
end


Then /^an error "([^\"]*)" raised$/ do | message |
  @error.should_not be_nil
  @error.message.should == message
end


Then /^エラー "([^\"]*)"$/ do | message |
  Then %{an error "#{ message }" raised}
end


Then /^エラー$/ do
  @error.should_not be_nil
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
