When /^I try to setup nfsd for installer "([^\"]*)"$/ do | installer |
  @messenger = StringIO.new( "" )
  nfs_service = Service::Nfs.new( :dry_run => true, :verbose => true, :messenger => @messenger )
  nfs_service.setup Nodes.load_all, Installers.find( installer )
end


Then /^nfsd should reload the new configuration$/ do
  @messenger.string.split( "\n" ).inject( false ) do | result, each |
    result ||= Regexp.new( /\/etc\/init\.d\/nfs\-kernel\-server (start|restart)/ )=~ each
  end.should be_true
end


Then /^nfsd configuration includes an entry for node "([^\"]*)"$/ do | name |
  history.inject( false ) do | result, each |
    result ||= Regexp.new( Nodes.find( name ).ip_address )=~ each
  end.should be_true
end


Then /^nfsd configuration should have no entry$/ do
  history.should == [ "Setting up nfsd ..." ]
end


Then /^nfsd should not be refreshed$/ do
  @messenger.string.should == "Setting up nfsd ...\n"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
