When /^I add an installer$/ do
  @messenger = StringIO.new( "" )
  Installers.add Installer.new, { :verbose => @verbose, :dry_run => @dry_run }, @messenger
end


Then /^temporary directory for the installer created$/ do
  dir = File.join( Configuration.temporary_directory, "installers", @suite )
  history.should include( "mkdir -p #{ dir }" )
end


Then /^an installer added$/ do
  installer = Installers.find( @suite )
  installer.suite.should == @suite
  installer.http_proxy.should be_nil
  installer.package_repository.should == "http://cdn.debian.or.jp/debian"
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
