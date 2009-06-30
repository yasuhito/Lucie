Given /^install option for node "([^\"]*)" is "([^\"]*)"$/ do | node, options |
  @node_argv ||= {}
  @node_argv[ node ] = options.split( /\s+/ )
end


When /^I try to run 'node install\-multi', with option "([^\"]*)", and nodes "([^\"]*)"$/ do | options, nodes |
  pending
  @messenger = StringIO.new( "" )
  begin
    Command::NodeInstallMulti::App.new( options.split( /\s+/ ) + [ "--verbose", "--dry-run" ], @messenger, [ @if ] ).main( @node_argv )
  rescue => e
    @last_error = e
  end
end


Then /^nodes "([^\"]*)" installed$/ do | nodes |
  @last_error.should == nil
  nodes.split( /,\s*/ ).each do | each |
    history.should include( "Node '#{ each }' installed." )
  end
end


Then /^nodes "([^\"]*)" installed using storage conf "([^\"]*)"$/ do | nodes, storage_conf |
  @last_error.should == nil
  nodes.split( /,\s*/ ).each do | each |
    history.should include( "node #{ each } is going to be installed using #{ storage_conf }" )
  end
end


Then /^error "([^\"]*)" raised$/ do | message |
  @last_error.should_not == nil
  @last_error.message.should == message
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
