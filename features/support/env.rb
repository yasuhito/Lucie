require "spec"


################################################################################
# Load Lucie libraries
################################################################################


$LOAD_PATH.unshift File.join( File.dirname( __FILE__ ), "/../../lib" )

require "lucie"

require "command/node-install"
require "command/node-install-multi"
require "command/node-update"
require "confidential-data-server"
require "configuration-updator"
require "configurator"


################################################################################
# Helper classes
################################################################################

class SuccessfulDpkg
  def installed? scm
    true
  end


  def installed_on? node, scm
    true
  end
end


class FailingDpkg
  def installed? scm
    false
  end


  def installed_on? node, scm
    false
  end
end


DummyInterface = Struct.new( :ip_address, :netmask, :subnet )


################################################################################
# Helper methods
################################################################################


# [FIXME] obsolete.
def options
  { :dry_run => true,
    :verbose => @verbose,
    :messenger => @messenger,
    :scm => @scm,
    :dummy_scm => @dummy_scm,
    :dpkg => @custom_dpkg,
    :repository_name => @repository_name,
    :home => @home,
    :lucie_home => @lucie_home,
    :nic => [ @if ] }
end


def debug_options
  options
end


def regexp_from string
  Regexp.escape string
end


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


def history
  @messenger.string.split "\n"
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
