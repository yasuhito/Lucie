When /^I try to setup approx$/ do
  @messenger = StringIO.new( "" )
  Service::Approx.new( :verbose => true, :dry_run => true, :messenger => @messenger ).setup "DEBIAN_REPOSITORY"
end


Then /^approx configuration file generated$/ do
  history.should include( "file write (/etc/approx/approx.conf)" )
end


Then /^approx restarted$/ do
  history.should include( "sudo /etc/init.d/approx restart" )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
