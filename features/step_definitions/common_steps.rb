# -*- coding: utf-8 -*-
Given /^the rake task list cleared$/ do
  Rake::Task.clear
end


Given /^eth0 "(.*)"$/ do | ip |
  @if = DummyInterface.new( ip, "255.255.255.0", Network.network_address( ip, "255.255.255.0" ) )
end


Given /^Lucie log path is "([^\"]*)"$/ do | path |
  FileUtils.mkdir_p File.dirname( path )
  Lucie::Log.path = path
end


Given /^installers temporary directory is "([^\"]*)"$/ do | path |
  Configuration.installers_temporary_directory = path
  FileUtils.rm_rf Dir.glob( File.join( Configuration.installers_temporary_directory, "*" ) )
end

Given /^Lucie log directory "([^\"]*)" is empty$/ do | path |
  Configuration.log_directory = path
  FileUtils.rm_rf Dir.glob( File.join( Configuration.log_directory, "*" ) )
end


Given /^temporary directory "([^\"]*)" is empty$/ do | path |
  Configuration.temporary_directory = path
  FileUtils.rm_rf Dir.glob( File.join( Configuration.temporary_directory, "*" ) )
end


Given /^log directory "([^\"]*)" is empty$/ do | path |
  Configuration.log_directory = path
  FileUtils.rm_rf Dir.glob( File.join( Configuration.log_directory, "*" ) )
end


Given /^\-\-verbose option is off$/ do
  @verbose = false
end


Given /^\-\-verbose option is on$/ do
  @verbose = true
end


Given /^\-\-dry\-run option is on$/ do
  @dry_run = true
end


Given /^\-\-dry\-run option is off$/ do
  @dry_run = false
end


Given /^a file "([^\"]*)" not exist$/ do | name |
  system "rm -f #{ name }"
end


Given /^a directory "([^\"]*)" not exist$/ do | name |
  system "rm -rf #{ name }"
end


Then /^"(.*)" displayed$/ do | line |
  history.should include( line )
end


Then /^nothing displayed$/ do
  history.should == []
end


Then /^nothing raised$/ do
  @last_error.should == nil
end


Then /^エラーが発生しない$/ do
  @error.should be_nil
end


Then /^an error "([^\"]*)" raised$/ do | message |
  @last_error.should_not == nil
  @last_error.message.should == message
end


Then /^エラー "([^\"]*)"$/ do | message |
  @error.should_not be_nil
  @error.message.should == message
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
