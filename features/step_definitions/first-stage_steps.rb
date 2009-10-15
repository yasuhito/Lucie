When /^I try to setup first stage environment for node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  first_stage = Environment::FirstStage.new( { :verbose => true, :dry_run => true }, @messenger )
  first_stage.start [ Nodes.find( name ) ], Installer.new, Tempfile.new( "inetd.conf" ).path, [ @if ]
end


When /^I run first stage installer with node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  html_logger = Lucie::Logger::HTML.new( :verbose => true, :dry_run => true, :messenger => @messenger )
  html_logger.start( { :suite => "lenny", :ldb_repository => "http://ldb.repository.org/", :package_repository => "http://cdn.debian.org/", :http_proxy => "http://proxy.org:3128/" } )
  logger = Lucie::Logger::Installer.new( "/tmp/lucie/log/", true )
  first_stage = FirstStage.new( Nodes.find( name ), "lenny", "linux-image-686", "base.tgz", "./my_storage.conf", "LDB_DIRECTORY", logger, html_logger, { :dry_run => true }, @messenger )
  first_stage.run
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
