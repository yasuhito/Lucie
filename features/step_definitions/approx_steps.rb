When /^I try to setup approx$/ do
  @messenger = StringIO.new
  approx = Service::Approx.new( :verbose => true, :dry_run => true, :messenger => @messenger )
  approx.setup "DEBIAN_REPOSITORY"
end


Then /^an approx configuration file generated$/ do
  history.should include( "file write (/etc/approx/approx.conf)" )
end


Then /^the approx configuration file should include debian repository$/ do
  @messenger.string.should match( /^> debian\s+DEBIAN_REPOSITORY$/ )
end


Then /^the approx configuration file should include security repository$/ do
  security_repository = regexp_from( "http://security.debian.org/debian-security" )
  @messenger.string.should match( /^> security\s+#{ security_repository }$/ )
end


Then /^the approx configuration file should include volatile repository$/ do
  volatile_repository = regexp_from( "http://volatile.debian.org/debian-volatile" )
  @messenger.string.should match( /^> volatile\s+#{ volatile_repository }$/ )
end


Then /^approx restarted$/ do
  history.should include( "sudo /etc/init.d/approx restart" )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
