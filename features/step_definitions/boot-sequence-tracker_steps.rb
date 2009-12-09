Given /^boot sequence tracker started for node "([^\"]*)"$/ do | name |
  @node = Nodes.find( name )
  @messenger = StringIO.new
  @debug_options = { :dry_run => true, :verbose => true, :messenger => @messenger }
end


When /^I try to wait until node "([^\"]*)" boots with PXE$/ do | name |
  BootSequenceTracker.new( StringIO.new( <<-SYSLOG ), @node, "LOGGER", @debug_options ).wait_pxe
Jun 17 21:00:15 lucie_server in.tftpd[12345]: RRQ from #{ @node.ip_address } filename pxelinux.0
Jun 17 21:00:16 lucie_server in.tftpd[12345]: RRQ from #{ @node.ip_address } filename pxelinux.cfg/01-#{ @node.mac_address.gsub( ":", "-" ) }
Jun 17 21:00:17 lucie_server in.tftpd[12345]: RRQ from #{ @node.ip_address } filename lucie
SYSLOG
end


When /^I try to wait until node "([^\"]*)" boots from local hard disk with PXE$/ do | name |
  BootSequenceTracker.new( StringIO.new( <<-SYSLOG ), @node, "LOGGER", @debug_options ).wait_pxe_localboot
Jun 17 21:00:15 lucie_server in.tftpd[12345]: RRQ from #{ @node.ip_address } filename pxelinux.0
Jun 17 21:00:16 lucie_server in.tftpd[12345]: RRQ from #{ @node.ip_address } filename pxelinux.cfg/01-#{ @node.mac_address.gsub( ":", "-" ) }
SYSLOG
end


When /^I try to wait until dhcpd sends DCHPACK to node "([^\"]*)"$/ do | name |
  BootSequenceTracker.new( StringIO.new( <<-SYSLOG ), @node, "LOGGER", @debug_options ).wait_dhcpack
Jun 17 21:00:18 lucie_server dhcpd: DHCPDISCOVER from #{ @node.mac_address } via eth0
Jun 17 21:00:19 lucie_server dhcpd: DHCPOFFER on #{ @node.ip_address } to #{ @node.mac_address } via eth0
Jun 17 21:00:20 lucie_server dhcpd: DHCPREQUEST for #{ @node.ip_address } (192.168.0.1) from #{ @node.mac_address } via eth0
Jun 17 21:00:21 lucie_server dhcpd: DHCPACK on #{ @node.ip_address } to #{ @node.mac_address } via eth0
SYSLOG
end


When /^I try to wait until nfsroot mounted from node "([^\"]*)"$/ do | name |
  BootSequenceTracker.new( StringIO.new( <<-SYSLOG ), @node, "LOGGER", @debug_options ).wait_nfsroot
Jun 17 21:00:18 lucie_server mountd[12345]: authenticated mount request from #{ @node.ip_address }:885 for /home/lucie/installers/lenny/nfsroot (/home/lucie/installers/lenny/nfsroot)
SYSLOG
end


When /^I try to wait until node responds to ping$/ do
  BootSequenceTracker.new( StringIO.new, @node, "LOGGER", @debug_options ).wait_pong
end


When /^I try to wait until node not responds to ping$/ do
  BootSequenceTracker.new( StringIO.new, @node, "LOGGER", @debug_options ).wait_no_pong
end


When /^I try to wait until sshd is up$/ do
  BootSequenceTracker.new( StringIO.new, @node, "LOGGER", @debug_options ).wait_sshd
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
