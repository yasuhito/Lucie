When /^I try to load installers$/ do
  @installers = Installers.load_all
end


When /^I try to find an installer "([^\"]*)"$/ do | name |
  @found_installer = Installers.find( name )
end


When /^I try to remove an installer "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  Installers.remove! name, { :verbose => @verbose, :dry_run => @dry_run }, @messenger
end


When /^I add an installer named "([^\"]*)" twice$/ do | name |
  2.times do
    Installers.add Installer.new( name, installer_directory( name ) ) rescue @error_message = $!.to_s
  end
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


Then /^an installer "([^\"]*)" loaded$/ do | suite |
  @found_installer.suite.should == suite
end


Then /^no installer found$/ do
  @found_installer.should == nil
end


Then /^installer "([^\"]*)" removed$/ do | name |
  Installers.find( name ).should == nil
end


Then /^no error should be raised by removing nonexistent installer$/ do
  # do nothing.
end


Then /^an error "([^\"]*)" should be raised$/ do | err_msg |
  @error_message.should == err_msg
end


Then /^configuration example for installer "([^\"]*)" should be generated$/ do | name |
  FileTest.exists?( File.join( Configuration.installers_temporary_directory, name, "config.rb" ) ).should be_true
end


Then /^a directory for installer "([^\"]*)" should be created$/ do | name |
  FileTest.directory?( File.join( Configuration.installers_temporary_directory, name ) ).should be_true
end


Then /^I can find a installer "([^\"]*)"$/ do | suite |
  installer = Installers.find( suite )
  installer.should_not == nil
  installer.suite.should == suite
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
