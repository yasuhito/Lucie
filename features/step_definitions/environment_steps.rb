When /^I try to setup installation envrionemt for "([^\"]*)" with installer "([^\"]*)"$/ do | node, installer |
  @messenger = StringIO.new( "" )
  @tftpd_config = Tempfile.new( "tftp" )
  @nfsd_config = Tempfile.new( "nfs" )
  @dhcpd_config = Tempfile.new( "dhcp" )
  configs = { :tftpd => @tftpd_config.path, :nfsd => @nfsd_config.path, :dhcpd => @dhcpd_config.path }
  options = { :verbose => true, :dry_run => true }
  Environment::Install.new( options, @messenger, configs ).__send__ :setup, Nodes.find( node ), Installers.find( installer ), [ @if ]
end


When /^I try to teardown installation environment for "([^\"]*)" with installer "([^\"]*)"$/ do | node, installer |
  @messenger = StringIO.new( "" )
  env = Environment::Install.new( { :verbose => true, :dry_run => true }, @messenger )
  env.__send__ :teardown, Nodes.find( node ), Installers.find( installer )
end
