When /^I try to load installers$/ do
  @installers = Installers.load_all
end


When /^I try to find an installer "([^\"]*)"$/ do | name |
  @found_installer = Installers.find( name )
end


When /^I try to get a size of installer list$/ do
  @installers_size = Installers.size
end


When /^I try to sort installers$/ do
  @sorted_installers = Installers.sort
end


Then /^the installer list size should be (\d+)$/ do | size |
  @installers_size.should == size.to_i
end


Then /^installer list should be empty$/ do
  @installers.should be_empty
end


Then /^installer list has exactly (\d+) installer\(s\)$/ do | num |
  @installers.should have( num.to_i ).installers
end


Then /^installer list includes a installer "([^\"]*)"$/ do | suite |
  @installers.inject( false ) do | result, each |
    result ||= ( each.suite == suite )
  end.should be_true
end


Then /^an installer "([^\"]*)" loaded$/ do | name |
  @found_installer.name.should == name
end


Then /^no installer found$/ do
  @found_installer.should == nil
end


Then /^no error should be raised by removing nonexistent installer$/ do
  # do nothing.
end


Then /^configuration example for the installer should be generated$/ do
  config = File.join( Configuration.installers_temporary_directory, "#{ @suite }_#{ arch }", "config.rb" )
  history.should include( "file write (#{ config })" )
end


Then /^a directory for the installer should be created$/ do
  dir = File.join( Configuration.installers_temporary_directory, "#{ @suite }_#{ arch }" )
  history.should include( "mkdir -p #{ dir }" )
end


Then /^I can find a installer "([^\"]*)"$/ do | name |
  installer = Installers.find( name )
  installer.should_not == nil
  installer.name.should == name
end


Then /^I should get a sorted installer list "([^\"]*)"$/ do | list |
  @sorted_installers.each_with_index do | each, index |
    list.split( /,\s+/ )[ index ].should == each.suite
  end
end


Then /^the installer list size is (\d+)$/ do | size |
  Installers.size.should == size.to_i
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
