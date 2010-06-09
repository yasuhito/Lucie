Given /^nfsroot target directory is "([^\"]*)"$/ do | dir |
  @target_directory = dir
end


When /^I try to build nfsroot$/ do
  @messenger = StringIO.new( "" )
  Nfsroot.configure do | n |
    n.http_proxy = @http_proxy
    n.package_repository = @package_repository
    n.root_password = @root_password
    n.sources_list = @sources_list
    n.suite = @suite
    n.target_directory = @target_directory
    n.arch = "i386"

    n.messenger = @messenger
    n.dry_run = true
    n.verbose = true
  end
  Rake::Task[ "installer:nfsroot" ].invoke
end


Then /^nfsroot created on "([^\"]*)"$/ do | path |
  history.should include( "nfsroot created on #{ path }." )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
