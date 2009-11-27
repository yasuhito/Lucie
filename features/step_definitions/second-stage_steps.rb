When /^I try to start second stage for node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  second_stage = Environment::SecondStage.new( :verbose => true, :dry_run => true, :messenger => @messenger )
  second_stage.start Nodes.find( name )
end


Then /^network boot is disabled for a node with MAC address "([^\"]*)"$/ do | mac_address |
  pxe_cfg = File.join( Configuration.tftp_root, "pxelinux.cfg", "01-" + mac_address.gsub( ":", "-" ).downcase )
  history.should include( "file write (#{ pxe_cfg })" )
  history.should include( "> default local" )
  history.should include( "> label local" )
  history.should include( "> localboot 0" )
end
