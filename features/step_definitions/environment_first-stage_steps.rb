When /^I try to setup first stage environment for node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new
  debug_options = { :verbose => true, :dry_run => true, :messenger => @messenger, :nic => [ @if ], :inetd_conf => Tempfile.new( "lucie" ).path }
  Environment::FirstStage.new( [ Nodes.find( name ) ], Installer.new, debug_options ).start
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
