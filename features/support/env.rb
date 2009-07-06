require "spec"


################################################################################
# Load Lucie libraries
################################################################################


$LOAD_PATH.unshift File.join( File.dirname( __FILE__ ), "/../../lib" )


require "lucie"
require "command/node-install"
require "command/node-install-multi"
require "command/node-update"
require "secret-server"


################################################################################
# Helper classes
################################################################################


DummyInterface = Struct.new( :ip_address, :netmask, :subnet )


################################################################################
# Helper methods
################################################################################


def successful_boot_syslog_of node
  return <<-SYSLOG
Jun 17 21:00:18 lucie_server dhcpd: DHCPDISCOVER from #{ node.mac_address } via eth0
Jun 17 21:00:19 lucie_server dhcpd: DHCPOFFER on #{ node.ip_address } to #{ node.mac_address } via eth0
Jun 17 21:00:20 lucie_server dhcpd: DHCPREQUEST for #{ node.ip_address } (192.168.0.1) from #{ node.mac_address } via eth0
Jun 17 21:00:21 lucie_server dhcpd: DHCPACK on #{ node.ip_address } to #{ node.mac_address } via eth0
Jun 17 21:00:22 lucie_server in.tftpd[12345]: RRQ from #{ node.ip_address } filename pxelinux.0
Jun 17 21:00:23 lucie_server in.tftpd[12345]: RRQ from #{ node.ip_address } filename pxelinux.cfg/01-#{ node.mac_address.gsub( ":", "-" ) }
Jun 17 21:00:24 lucie_server in.tftpd[12345]: RRQ from #{ node.ip_address } filename lucie
Jun 17 21:00:25 lucie_server dhcpd: DHCPDISCOVER from #{ node.mac_address } via eth0
Jun 17 21:00:26 lucie_server dhcpd: DHCPOFFER on #{ node.ip_address } to #{ node.mac_address } via eth0
Jun 17 21:00:27 lucie_server dhcpd: DHCPREQUEST for #{ node.ip_address } (192.168.0.1) from #{ node.mac_address } via eth0
Jun 17 21:00:28 lucie_server dhcpd: DHCPACK on #{ node.ip_address } to #{ node.mac_address } via eth0
Jun 17 21:00:29 lucie_server mountd[12345]: authenticated mount request from #{ node.ip_address }:885 for /home/lucie/installers/lenny/nfsroot (/home/lucie/installers/lenny/nfsroot)
SYSLOG
end


def strip_tags html
  html.sub!(/<[^<>]*>/,"") while /<[^<>]*>/ =~ html
  html
end


def log_directory name
  File.join Configuration.log_directory, name
end


def history
  @messenger.string.split "\n"
end


def show_history
  history.each do | each |
    $stderr.puts each
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
