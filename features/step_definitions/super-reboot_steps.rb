Given /^reboot script "([^\"]*)"$/ do | path |
  @reboot_script = path
end


When /^I start first stage of node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  syslog = StringIO.new( successful_boot_syslog_of Nodes.find( name ) )
  super_reboot = SuperReboot.new( Nodes.find( name ), syslog, Lucie::Logger::Null.new, { :dry_run => true, :verbose => true, :messenger => @messenger } )
  super_reboot.start_first_stage @reboot_script
end


When /^I start second stage of node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  syslog = StringIO.new( successful_boot_syslog_of Nodes.find( name ) )
  super_reboot = SuperReboot.new( Nodes.find( name ), syslog, Lucie::Logger::Null.new, { :dry_run => true, :verbose => true, :messenger => @messenger } )
  super_reboot.start_second_stage
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
