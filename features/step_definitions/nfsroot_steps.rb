Given /^nfsroot target directory is "([^\"]*)"$/ do | dir |
  @target_directory = dir
end


Given /^kernel package is "([^\"]*)"$/ do | deb |
  @kernel_package = deb
end


Given /^kernel version is "([^\"]*)"$/ do | version |
  @kernel_version = version
end


When /^I try to build nfsroot$/ do
  @messenger = StringIO.new( "" )
  Nfsroot.configure do | n |
    n.http_proxy = @http_proxy
    n.kernel_package = @kernel_package
    n.package_repository = @package_repository
    n.root_password = @root_password
    n.sources_list = @sources_list
    n.suite = @suite
    n.target_directory = @target_directory

    n.kernel_version = @kernel_version
    n.messenger = @messenger
    n.dry_run = true
    n.verbose = true
  end
  Rake::Task[ "installer:nfsroot" ].invoke
end


Then /^nfsroot created on "([^\"]*)"$/ do | path |
  history.should include( "nfsroot created on #{ path }." )
end

