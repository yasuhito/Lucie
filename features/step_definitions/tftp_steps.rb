Given /^tftp root path is "([^\"]*)"$/ do | path |
  Configuration.tftp_root = path
end


Given /^RUN_DAEMON option of tftpd default config is "([^\"]*)"$/ do | yesno |
  @tftpd_config = Tempfile.new( 'tftp' )
  @tftpd_config.puts %{RUN_DAEMON="#{ yesno.downcase }"}
  @tftpd_config.flush
end


Given /^command line option of default config is "(.*)"$/ do | option |
  @tftpd_config.puts %{OPTIONS="#{ option }"}
  @tftpd_config.flush
end


Given /^"inetd\.conf has tftpd entry\?" is "([^\"]*)"$/ do | yesno |
  if yesno.downcase == "yes"
    inetd_conf = Tempfile.new( "lucie test" )
    inetd_conf.puts "tftp dgram udp wait root /usr/sbin/in.tftpd /usr/sbin/in.tftpd -s /var/lib/tftpboot"
    inetd_conf.close
    @inetd_conf = inetd_conf.path
  end
end


When /^I try to setup tftpd nfsroot with installer "([^\"]*)"$/ do | installer |
  @messenger = StringIO.new( "" )
  Service::Tftp.__send__ :class_variable_set, :@@config, @tftpd_config ? @tftpd_config.path : "/etc/default/tftpd-hpa"
  tftp_service = Service::Tftp.new( { :verbose => true, :dry_run => true }, @messenger )
  tftp_service.setup_nfsroot Nodes.load_all, Installers.find( installer ), @inetd_conf
end


Then /^PXE directory should be created$/ do
  history.should include( "sudo mkdir -p #{ File.join( Configuration.tftp_root, 'pxelinux.cfg' ) }" )
end


Then /^"tftpd config generated\?" is "([^\"]*)"$/ do | yesno |
  expected = "file write (#{ @tftpd_config.path })"
  if yesno.downcase == 'yes'
    history.should include( expected )
  else
    history.should_not include( expected )
  end
end


Then /^PXE configuration file for node "([^\"]*)" should be generated$/ do | node_name |
  mac = Nodes.find( node_name ).mac_address
  config = File.join( Configuration.tftp_root, 'pxelinux.cfg', "01-#{ mac.gsub( ':', '-' ).downcase }" )
  history.should include( "file write (#{ config })" )
end


Then /^"tftpd restarted\?" is "([^\"]*)"$/ do | yesno |
  expected = "sudo /etc/init.d/tftpd-hpa restart"
  if yesno.downcase == 'yes'
    history.should include( expected )
  else
    history.should_not include( expected )
  end
end


Then /^"inetd\.conf updated\?" is "([^\"]*)"$/ do | yesno |
  expected = "sudo /usr/sbin/update-inetd --disable tftp"
  if yesno.downcase == 'yes'
    history.should include( expected )
  else
    history.should_not include( expected )
  end
end


Then /^"inetd restarted\?" is "([^\"]*)"$/ do | yesno |
  expected = "sudo kill -HUP `cat /var/run/inetd.pid`"
  if yesno.downcase == 'yes'
    history.should include( expected )
  else
    history.should_not include( expected )
  end
end


When /^I try to setup tftpd localboot for node "([^\"]*)"$/ do | node |
  @messenger = StringIO.new( "" )
  tftp_service = Service::Tftp.new( { :dry_run => true, :verbose => true }, @messenger )
  tftp_service.setup_localboot Nodes.find( node )
end


Then /^PXE configuration file for node "([^\"]*)" should be modified to boot from local$/ do | node_name |
  mac_file = "01-" + Nodes.find( node_name ).mac_address.gsub( ':', '-' ).downcase
  history[ 0..4 ].should == ( <<-EXPECTED ).split( "\n" )
file write (#{ File.join( Configuration.tftp_root, 'pxelinux.cfg', mac_file ) })
> default local
> 
> label local
> localboot 0
EXPECTED
end


When /^I try to remove tftpd configuration for node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  @tftpd_config = Tempfile.new( "tftp" )
  tftp_service = Service::Tftp.new( { :dry_run => true, :verbose => true }, @messenger )
  tftp_service.remove Nodes.find( name )
end


Then /^PXE configuration file for node "([^\"]*)" removed$/ do | name |
  mac = "01-" + Nodes.find( name ).mac_address.gsub( ':', '-' ).downcase
  expected = Regexp.new( Regexp.escape( "rm -f " + File.join( Configuration.tftp_root, 'pxelinux.cfg', mac ) ) )
  @messenger.string.should match( expected )
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
