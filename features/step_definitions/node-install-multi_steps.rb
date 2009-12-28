Given /^install option for node "([^\"]*)" is "([^\"]*)"$/ do | node, options |
  @node_argv ||= []
  @node_argv << "#{ node } #{ options }"
end


When /^I try to run 'node install\-multi' with global option "([^\"]*)"$/ do | global_option |
  @messenger = StringIO.new
  @inetd_conf = Tempfile.new( "lucie" ).path
  debug_options = { :messenger => @messenger, :verbose => true, :nic => [ @if ], :inetd_conf => @inetd_conf, :dpkg => SuccessfulDpkg.new }
  Command::NodeInstallMulti::App.new( @node_argv + global_option.split( /\s+/ ) + [ "--dry-run" ], debug_options ).main
end


Then /^node "([^\"]*)" installed using storage conf "([^\"]*)"$/ do | node, storage_conf |
  history.should include( "node #{ node } is going to be installed using #{ storage_conf }" )
end


Then /^node "([^\"]*)" installed$/ do | node |
  history.should include( "Node '#{ node }' installed." )
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
