When /^I try to setup dhcpd$/ do
  @messenger = StringIO.new( "" )
  dhcp_service = Service::Dhcp.new( { :verbose => true, :dry_run => true }, @messenger )
  begin
    dhcp_service.setup Nodes.load_all, [ @if ]
  rescue => e
    @last_error = e
  end
end


When /^I try to disable dhcpd$/ do
  @messenger = StringIO.new( "" )
  dhcp_service = Service::Dhcp.new( { :verbose => true, :dry_run => true }, @messenger )
  dhcp_service.disable
end


Then /^dhcpd configuration should include (\d+) node\(s\)$/ do | nentry |
  history.inject( 0 ) do | result, each |
    result += 1 if /^>\s+host .* \{/=~ each
    result
  end.should == nentry.to_i
end


Then /^dhcpd should reload the new configuration$/ do
  history.inject( false ) do | result, each |
    result ||= Regexp.new( /\/etc\/init\.d\/dhcp3\-server (start|restart)/ ) === each
  end.should be_true
end


Then /^dhcpd should not reload configuration$/ do
  history.inject( false ) do | result, each |
    result ||= Regexp.new( /\/etc\/init\.d\/dhcp3\-server (start|restart)/ ) === each
  end.should be_false
end


Then /^dhcpd configuration should include an entry for node "([^\"]*)"$/ do | host_name |
  history.should include( ">   host #{ host_name } {" )
end


Then /^dhcpd configuration should not include an entry for node "([^\"]*)"$/ do | host_name |
  history.should_not include( ">   host #{ host_name } {" )
end


Then /^dhcpd configuration file removed$/ do
  @messenger.string.should match( /rm -f \/etc\/dhcp3\/dhcpd\.conf/ )
end


Then /^dhcpd should be stopped$/ do
  history.inject( false ) do | result, each |
    result ||= Regexp.new( /\/etc\/init\.d\/dhcp3\-server stop/ ) === each
  end.should be_true
end


Then /^dhcpd configuration should not include node entry$/ do
  history.inject( false ) do | result, each |
    result ||= /^>\s+host .* \{/ === each
  end.should be_false
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
