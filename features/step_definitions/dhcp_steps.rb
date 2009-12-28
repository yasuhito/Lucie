When /^I try to setup dhcpd$/ do
  @messenger = StringIO.new
  dhcp_service = Service::Dhcp.new( :verbose => true, :dry_run => true, :messenger => @messenger, :nic => [ @if ] )
  begin
    dhcp_service.setup Nodes.load_all
  rescue => e
    @error = e
  end
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
