When /^I run node update "([^\"]*)"$/ do | nodes |
  @messenger = StringIO.new( "" )
  argv = ( @dry_run ? [ "--verbose", "--dry-run" ] : [ "--verbose" ] )
  begin
    Command::NodeUpdate::App.new( argv, @messenger,  @if ? [ @if ] : nil ).main nodes.split( /,\s*/ )
  rescue => e
    @last_error = e
  end
end


Then /^remote repository cloned to Lucie server$/ do
  history.join( "\n" ).should match( /^hg clone/ )
end


Then /^ldb on Lucie server updated$/ do
  history.join( "\n" ).should match( /^hg pull/ )
  history.join( "\n" ).should match( /^hg update/ )
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
