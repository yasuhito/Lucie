When /^I run node install with "([^\"]*)" option with value "([^\"]*)"$/ do | option, value |
  @options = Command::NodeInstall::Options.new.parse( [ "#{ option }=#{ value }" ] )
end


Then /^address option should be "([^\"]*)"$/ do | value |
  @options.address.should == value
end


Then /^netmask option should be "([^\"]*)"$/ do | value |
  @options.netmask.should == value
end


Then /^mac option should be "([^\"]*)"$/ do | value |
  @options.mac.should == value
end


When /^I run node install with "([^\"]*)" option$/ do | option |
  @options = Command::NodeInstall::Options.new.parse( [ option ] )
end


Then /^dry\-run option should be on$/ do
  @options.dry_run.should be_true
end


Then /^verbose option should be on$/ do
  @options.verbose.should be_true
end


Then /^help option should be on$/ do
  @options.help.should_not be_nil
end


Then /^reboot script option should be on$/ do
  @options.reboot_script.should_not be_nil
end
