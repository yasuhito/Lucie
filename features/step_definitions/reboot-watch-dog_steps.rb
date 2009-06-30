Given /^reboot\-watchdog started for node "([^\"]*)"$/ do | name |
  @messenger = StringIO.new( "" )
  @reboot_watch_dog = RebootWatchDog.new( Nodes.find( name ), { :dry_run => true, :verbose => true }, @messenger )
end


When /^I try to wait until node "([^\"]*)" boots with PXE$/ do | name |
  node = Nodes.find( name )
  @reboot_watch_dog.syslog = StringIO.new( <<-SYSLOG )
Jun 17 21:00:15 lucie_server in.tftpd[12345]: RRQ from #{ node.ip_address } filename pxelinux.0
Jun 17 21:00:16 lucie_server in.tftpd[12345]: RRQ from #{ node.ip_address } filename pxelinux.cfg/01-#{ node.mac_address.gsub( ":", "-" ) }
Jun 17 21:00:17 lucie_server in.tftpd[12345]: RRQ from #{ node.ip_address } filename lucie
SYSLOG
  @reboot_watch_dog.wait_pxe
end


When /^I try to wait until node "([^\"]*)" boots from local hard disk with PXE$/ do | name |
  node = Nodes.find( name )
  @reboot_watch_dog.syslog = StringIO.new( <<-SYSLOG )
Jun 17 21:00:15 lucie_server in.tftpd[12345]: RRQ from #{ node.ip_address } filename pxelinux.0
Jun 17 21:00:16 lucie_server in.tftpd[12345]: RRQ from #{ node.ip_address } filename pxelinux.cfg/01-#{ node.mac_address.gsub( ":", "-" ) }
SYSLOG
  @reboot_watch_dog.wait_pxe_localboot
end


When /^I try to wait until dhcpd sends DCHPACK to node "([^\"]*)"$/ do | name |
  node = Nodes.find( name )
  @reboot_watch_dog.syslog = StringIO.new( <<-SYSLOG )
Jun 17 21:00:18 lucie_server dhcpd: DHCPDISCOVER from #{ node.mac_address } via eth0
Jun 17 21:00:19 lucie_server dhcpd: DHCPOFFER on #{ node.ip_address } to #{ node.mac_address } via eth0
Jun 17 21:00:20 lucie_server dhcpd: DHCPREQUEST for #{ node.ip_address } (192.168.0.1) from #{ node.mac_address } via eth0
Jun 17 21:00:21 lucie_server dhcpd: DHCPACK on #{ node.ip_address } to #{ node.mac_address } via eth0
SYSLOG
  @reboot_watch_dog.wait_dhcpack
end


When /^I try to wait until nfsroot mounted from node "([^\"]*)"$/ do | name |
  node = Nodes.find( name )
  @reboot_watch_dog.syslog = StringIO.new( <<-SYSLOG )
Jun 17 21:00:18 lucie_server mountd[12345]: authenticated mount request from #{ node.ip_address }:885 for /home/lucie/installers/lenny/nfsroot (/home/lucie/installers/lenny/nfsroot)
SYSLOG
  @reboot_watch_dog.wait_nfsroot
end


When /^I try to wait until node responds to ping$/ do
  @reboot_watch_dog.wait_pong
end


When /^I try to wait until node not responds to ping$/ do
  @reboot_watch_dog.wait_no_pong
end


When /^I try to wait until sshd is up$/ do
  @reboot_watch_dog.wait_sshd
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
