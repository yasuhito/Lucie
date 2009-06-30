Given /^remote repository "([^\"]*)"$/ do | url |
  @hg_url = url
end


Given /^local repository is empty$/ do
  FileUtils.rm_rf Dir.glob( File.join( Configuration.temporary_directory, "*" ) )
end


Given /^local repository already exists$/ do
  FileUtils.mkdir_p File.join( Configuration.temporary_directory, "ldb", @hg_url.gsub( /[\/:]/, "_" ) )
  FileUtils.mkdir_p File.join( Configuration.temporary_directory, "ldb", @hg_url.gsub( /[\/:]/, "_" ) + ".local" )
end


When /^I update LDB on node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  logger = Lucie::Logger::Installer.new( "/tmp", true )
  @ldb = LDB.new( { :dry_run => true, :verbose => true }, @messenger, [ @if ] )
  @ldb.update Nodes.find( name ), @hg_url, logger
end


When /^I clone remote repository$/ do
  @messenger = StringIO.new( "" )
  logger = Lucie::Logger::Installer.new( "/tmp", true )
  @ldb = LDB.new( { :dry_run => true, :verbose => true }, @messenger, [ @if ] )
  @ldb.clone @hg_url, @if.ip_address, logger
end


When /^I start LDB on node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  logger = Lucie::Logger::Installer.new( "/tmp", true )
  @ldb = LDB.new( { :dry_run => true, :verbose => true }, @messenger, [ @if ] )
  @ldb.start Nodes.find( name ), @hg_url, logger
end


Then /^ldb installed on "([^\"]*)"$/ do | url |
  name, path = url.split( ':' )
  @messenger.string.should match( /hg clone/ )
  history.should include( "ldb installed on node #{ name }." )
  show_history
end


Then /^LDB on "([^\"]*)" updated$/ do | name |
  history.should include( "LDB updated on node #{ name }." )
end


Then /^repository cloned to local$/ do
  history.should include( "LDB #{ @hg_url } cloned to local." )
end


Then /^local repository updated$/ do
  history.should include( "clone and clone-clone LDB repositories on local updated." )
end


Then /^configurations updated on "([^\"]*)"$/ do | name |
  history.should include( "LDB executed on #{ name }." )
  @messenger.string.should match( /make/ )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
