Given /^install option for node "([^\"]*)" is "([^\"]*)"$/ do | node, options |
  @node_argv ||= []
  @node_argv << "#{ node } #{ options }"
end


When /^I try to run 'node install\-multi', with option "([^\"]*)", and nodes "([^\"]*)"$/ do | options, nodes |
  @messenger = StringIO.new
  begin
    debug_options = { :messenger => @messenger, :nic => [ @if ], :dpkg => SuccessfulDpkg.new }
    Command::NodeInstallMulti::App.new( @node_argv + options.split( /\s+/ ) + [ "--verbose", "--dry-run" ], debug_options ).main
  rescue => e
    @error = e
  end
end


Then /^nodes "([^\"]*)" installed$/ do | nodes |
  @error.should == nil
  nodes.split( /,\s*/ ).each do | each |
    history.should include( "Node '#{ each }' installed." )
  end
end


Then /^nodes "([^\"]*)" installed using storage conf "([^\"]*)"$/ do | nodes, storage_conf |
  @error.should == nil
  nodes.split( /,\s*/ ).each do | each |
    history.should include( "node #{ each } is going to be installed using #{ storage_conf }" )
  end
end


Then /^error "([^\"]*)" raised$/ do | message |
  @error.should_not == nil
  @error.message.should == message
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
