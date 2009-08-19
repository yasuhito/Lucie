When /^I try to load nodes$/ do
  @nodes = Nodes.load_all
end


Given /^node list is empty$/ do
  Nodes.clear
end


When /^I try to find a node "([^\"]*)"$/ do | name |
  @found_node = Nodes.find( name )
end


When /^I try to remove a node "([^\"]*)"$/ do | name |
  Nodes.remove! name rescue @error = $!
end


When /^I try to get a size of node list$/ do
  @nodes_size = Nodes.size
end


When /^I try to sort nodes by name$/ do
  @sorted_nodes = Nodes.sort
end


When /^a node named "([^\"]*)" added twice$/ do | name |
  opts = { :ip_address => '1.1.1.1', :netmask_address => '255.255.255.0', :mac_address => '00:00:00:00:00:00' }
  2.times do
    Nodes.add Node.new( name, opts ) rescue @error = $! 
  end
end


Then /^node list should be empty$/ do
  @nodes.should be_empty
end


Then /^node list should have exactly (\d+) node\(s\)$/ do | num |
  @nodes.should have( num.to_i ).nodes
end


Then /^node list should include a node "([^\"]*)"$/ do | name |
  @nodes.inject( false ) do | result, each |
    result ||= ( each.name == name )
  end.should be_true
end


Then /^no node found$/ do
  @found_node.should == nil
end


Then /^a node named "([^\"]*)" found$/ do | name |
  @found_node.should_not == nil
  @found_node.name.should == name
end


Then /^I can find a node named "([^\"]*)"$/ do | name |
  node = Nodes.find( name )
  node.should_not == nil
  node.name.should == name
end


Then /^a node named "([^\"]*)" removed$/ do | name |
  Nodes.find( name ).should == nil
end


Then /^the node list size is (\d+)$/ do | size |
  Nodes.size.should == size.to_i
end


Then /^I should get a sorted node list "([^\"]*)"$/ do | list |
  @sorted_nodes.each_with_index do | each, index |
    list.split( /,\s+/ )[ index ].should == each.name
  end
end


Then /^error "([^\"]*)" should be raised$/ do | message |
  @error.message.should == message
end


Then /^IP address of node "([^\"]*)" is "([^\"]*)"$/ do | name, address |
  Nodes.find( name ).ip_address.should == address
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
