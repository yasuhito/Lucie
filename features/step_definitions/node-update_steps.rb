When /^I run node update "([^\"]*)"$/ do | nodes |
  @messenger = StringIO.new
  @verbose = true
  Command::NodeUpdate::App.new( [], debug_options ).main nodes.split( /,\s*/ )
end


Then /^ldb on "([^\"]*)" executed$/ do | name |
  ip = Nodes.find( name ).ip_address
  history.join( "\n" ).should match( /ssh.*root@#{ ip }.* make/ )
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
