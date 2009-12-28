Given /^\-\-address option is "([^\"]*)"$/ do | value |
  @address = [ "--ip-address=#{ value }" ]
end


Given /^\-\-netmask option is "([^\"]*)"$/ do | value |
  @netmask = [ "--netmask=#{ value }" ]
end


Given /^\-\-mac option is "([^\"]*)"$/ do | value |
  @mac = [ "--mac=#{ value }" ]
end


Given /^\-\-storage\-conf option is "([^\"]*)"$/ do | value |
  @storage_conf = [ "--storage-conf=#{ value }" ]
end


When /^I run node install "([^\"]*)"$/ do | node |
  verbose = @verbose ? [ "--verbose" ] : []
  dry_run = @dry_run ? [ "--dry-run" ] : []
  opts = @address + @netmask + @mac + @storage_conf + verbose + dry_run
  @messenger = StringIO.new
  @inetd_conf = Tempfile.new( "lucie" ).path
  Command::NodeInstall::App.new( opts, :messenger => @messenger, :dry_run => true, :nic => [ @if ], :inetd_conf => @inetd_conf ).main( node )
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
