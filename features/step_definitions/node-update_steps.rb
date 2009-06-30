When /^I run node update "([^\"]*)"$/ do | nodes |
  @messenger = StringIO.new( "" )
  if @dry_run
    argv = [ "--ldb-repository", @hg_url, "--verbose", "--dry-run" ]
  else
    argv = [ "--ldb-repository", @hg_url, "--verbose" ]
  end
  begin
    Command::NodeUpdate::App.new( argv, @messenger,  @if ? [ @if ] : nil ).main nodes.split( /,\s*/ )
  rescue => e
    @last_error = e
  end
  show_history
end


Then /^remote repository cloned to Lucie server$/ do
  history.join( "\n" ).should match( /^hg clone/ )
end


Then /^ldb on Lucie server updated$/ do
  history.join( "\n" ).should match( /^hg pull/ )
  history.join( "\n" ).should match( /^hg update/ )
end


# Then /^ldb on "([^\"]*)" updated$/ do | name |
#   ip = Nodes.find( name ).ip_address
#   repository = Regexp.escape( @hg_url.gsub( /[\/:]/, "_" ) )
#   expected = Regexp.new( "ssh.*root@#{ ip }.*cd /var/lib/ldb/#{ repository } && hg pull" )
#   history.join( "\n" ).should match( expected )
# end


Then /^ldb on "([^\"]*)" executed$/ do | name |
  ip = Nodes.find( name ).ip_address
  history.join( "\n" ).should match( /ssh.*root@#{ ip }.* make/ )
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
