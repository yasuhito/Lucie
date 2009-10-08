require "lucie/debug"
require "ping"
require "socket"


class RebootWatchDog
  include Lucie::Debug


  DEFAULT_RETRY_INTERVAL = 2


  def initialize node, logger, debug_options = {}
    @node = node
    @logger = logger
    @debug_options = debug_options
  end


  def syslog= syslog
    @syslog = syslog
    @syslog.seek 0, IO::SEEK_END unless dry_run
  end


  def wait_pxe
    block_until_syslog_matches_with regexp_tftp_pxelinux, "waiting for #{ @node.name } to request PXE boot loader ..."
    block_until_syslog_matches_with regexp_tftp_pxelinux_cfg, "waiting for #{ @node.name } to request PXE boot loader configuration file ..."
    block_until_syslog_matches_with regexp_tftp_kernel, "waiting for #{ @node.name } to request Lucie kernel ..."
  end


  def wait_pxe_localboot
    block_until_syslog_matches_with regexp_tftp_pxelinux, "waiting for #{ @node.name } to request PXE boot loader ..."
    block_until_syslog_matches_with regexp_tftp_pxelinux_cfg, "waiting for #{ @node.name } to request PXE boot loader configuration file ..."
  end


  def wait_dhcpack
    block_until_syslog_matches_with regexp_dhcp_discover, "waiting for #{ @node.name } to send DHCPDISCOVER ..."
    block_until_syslog_matches_with regexp_dhcp_offer, "waiting for #{ @node.name } to receive DHCPOFFER ..."
    block_until_syslog_matches_with regexp_dhcp_request, "waiting for #{ @node.name } to send DHCPREQUEST ..."
    block_until_syslog_matches_with regexp_dhcp_ack, "waiting for #{ @node.name } to receive DHCPACK ..."
  end


  def wait_nfsroot
    block_until_syslog_matches_with regexp_nfs_mount, "waiting for #{ @node.name } to mount nfsroot ..."
  end


  def wait_pong
    wait_loop do
      debug "waiting for #{ @node.name } to respond to ping ..."
      dry_run || ping
    end
  end


  def wait_no_pong
    wait_loop do
      debug "waiting for #{ @node.name } to stop responding to ping ..."
      dry_run || ( not ping )
    end
  end


  def wait_sshd
    wait_loop do
      debug "waiting for sshd to start on #{ @node.name } ..."
      begin
        TCPSocket.open( @node.ip_address, 22 ) unless dry_run
        true
      rescue Errno::EHOSTUNREACH, Errno::ECONNREFUSED
        false
      end
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def wait_loop
    loop do
      break if yield
      sleep retry_interval
    end
  end


  def ping
    Ping.pingecho @node.ip_address, retry_interval
  end


  def block_until_syslog_matches_with regexp, message
    raise "syslog is not set" unless @syslog
    wait_loop do
      debug message
      tail regexp
    end
  end


  def tail regexp
    while line = @syslog.gets
      return true if regexp.match( line )
    end
    false
  end


  def retry_interval
    @debug_options[ :retry_interval ] || DEFAULT_RETRY_INTERVAL
  end


  # regular expressions ########################################################


  def regexp_tftp_kernel
    /in\.tftpd\[\d+\]: RRQ from #{ regexp( ip ) } filename lucie/
  end


  def regexp_tftp_pxelinux
    /in\.tftpd\[\d+\]: RRQ from #{ regexp( ip ) } filename pxelinux\.0/
  end


  def regexp_tftp_pxelinux_cfg
    /in\.tftpd\[\d+\]: RRQ from #{ regexp( ip ) } filename pxelinux\.cfg\/01\-#{ regexp( mac.gsub( ":", "-" ) ) }/
  end


  def regexp_dhcp_discover
    /dhcpd: DHCPDISCOVER from #{ mac }/
  end


  def regexp_dhcp_offer
    /dhcpd: DHCPOFFER on #{ regexp( ip ) } to #{ mac }/
  end


  def regexp_dhcp_request
    /dhcpd: DHCPREQUEST for #{ regexp( ip ) } .* from #{ mac }/
  end


  def regexp_dhcp_ack
    /dhcpd: DHCPACK on #{ regexp( ip ) } to #{ mac }/
  end


  def regexp_nfs_mount
    /mountd\[\d+\]: authenticated mount request from #{ regexp( ip ) }/
  end


  # Utils ######################################################################


  def ip
    @node.ip_address
  end


  def mac
    @node.mac_address.downcase
  end


  def regexp str
    Regexp.escape str
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
