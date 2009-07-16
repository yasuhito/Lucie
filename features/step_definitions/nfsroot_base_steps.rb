When /^I try to build nfsroot base$/ do
  @messenger = StringIO.new
  NfsrootBase.configure do | n |
    n.arch = @arch
    n.http_proxy = "http://localhost:8123/"
    n.include = [ "emacs23" ]
    n.package_repository = "http://myrepos/debian"
    n.suite = @suite

    n.messenger = @messenger
    n.dry_run = true
    n.verbose = true
  end
  Rake::Task[ "installer:nfsroot_base" ].invoke
end


Then /^nfsroot base tarball created on "([^\"]*)"$/ do | path |
  tgz = File.basename( path )
  history.should include( "tar --one-file-system --directory #{ Configuration.temporary_directory }/debootstrap --exclude #{ tgz } -czf #{ path } ." )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

