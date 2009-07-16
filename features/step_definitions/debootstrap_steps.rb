Given /^debootstrap installed$/ do
  @dpkg_l = %{echo "ii debootstrap DUMMY_VERSION"}
end


Given /^the rake task list cleared$/ do
  Rake::Task.clear
end


Given /^debootstrap not installed$/ do
  @dpkg_l = %{echo foobar}
end


Given /^suite is "([^\"]*)"$/ do | value |
  @suite = value
end


Given /^target is "([^\"]*)"$/ do | value |
  @target = value
end


Given /^package repository is "([^\"]*)"$/ do | value |
  @package_repository = value
end


Given /^suite is not set$/ do
  @suite = nil
end


Given /^target is not set$/ do
  @target = nil
end


Given /^package repository is not set$/ do
  @package_repository = nil
end


Given /^http proxy is "([^\"]*)"$/ do | proxy |
  @http_proxy = proxy
end


Given /^exclude is "([^\"]*)"$/ do | exclude |
  @exclude = exclude.split( /,\s*/ )
end


Given /^include is "([^\"]*)"$/ do | include |
  @include = include.split( /,\s*/ )
end


When /^I try to get debootstrap version$/ do
  @debootstrap_version = Debootstrap::VERSION( @dpkg_l )
end


When /^I try to start debootstrap$/ do
  @messenger = StringIO.new( "" )
  begin
    Debootstrap.setup do | d |
      d.exclude = @exclude
      d.http_proxy = @http_proxy
      d.include = @include
      d.package_repository = @package_repository
      d.suite = @suite
      d.target = @target
      
      d.verbose = true
      d.dry_run = true
      d.messenger = @messenger
    end
  rescue
    @error = $!
  end
end


Then /^I can get debootstrap version$/ do
  @debootstrap_version.should == "DUMMY_VERSION"
end


Then /^I cannot get debootstrap version$/ do
  @debootstrap_version.should == nil
end


Then /^debootstrap command "([^\"]*)" executed$/ do | command |
  @messenger.string.chomp.should == command
end


Then /^I should get debootstrap error "([^\"]*)"$/ do | error |
  @error.should_not be_nil
  @error.message.should == error
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
