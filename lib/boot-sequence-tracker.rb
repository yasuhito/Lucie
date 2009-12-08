require "boot-sequence-tracker/dhcpd-re"
require "boot-sequence-tracker/nfsd-re"
require "boot-sequence-tracker/tftpd-re"
require "lucie/debug"
require "ping"
require "socket"


class BootSequenceTracker
  include Lucie::Debug


  DEFAULT_RETRY_INTERVAL = 30


  def initialize node, logger, debug_options = {}
    @node_name = node.name
    @node_ip = node.ip_address
    @dhcpd_re = DhcpdRE.new( node )
    @nfsd_re = NfsdRE.new( node )
    @tftpd_re = TftpdRE.new( node )
    @logger = logger
    @debug_options = debug_options
  end


  def syslog= io
    @syslog = io
    @syslog.seek 0, IO::SEEK_END unless dry_run
  end


  def wait_pxe
    block_until_match @tftpd_re.pxelinux, "Waiting for #{ @node_name } to request PXE boot loader ..."
    block_until_match @tftpd_re.pxelinux_cfg, "Waiting for #{ @node_name } to request PXE boot loader configuration file ..."
    block_until_match @tftpd_re.kernel, "Waiting for #{ @node_name } to request Lucie kernel ..."
  end


  def wait_manual_reboot
    block_until_match @tftpd_re.pxelinux, "Please reboot #{ @node_name } manually."
    block_until_match @tftpd_re.pxelinux_cfg, "Waiting for #{ @node_name } to request PXE boot loader configuration file ..."
    block_until_match @tftpd_re.kernel, "Waiting for #{ @node_name } to request Lucie kernel ..."
  end


  def wait_pxe_localboot
    block_until_match @tftpd_re.pxelinux, "Waiting for #{ @node_name } to request PXE boot loader ..."
    block_until_match @tftpd_re.pxelinux_cfg, "Waiting for #{ @node_name } to request PXE boot loader configuration file ..."
  end


  def wait_dhcpack
    block_until_match @dhcpd_re.discover, "Waiting for #{ @node_name } to send DHCPDISCOVER ..."
    block_until_match @dhcpd_re.offer, "Waiting for #{ @node_name } to receive DHCPOFFER ..."
    block_until_match @dhcpd_re.request, "Waiting for #{ @node_name } to send DHCPREQUEST ..."
    block_until_match @dhcpd_re.ack, "Waiting for #{ @node_name } to receive DHCPACK ..."
  end


  def wait_nfsroot
    block_until_match @nfsd_re.mount, "Waiting for #{ @node_name } to mount nfsroot ..."
  end


  def wait_pong
    wait_loop do
      debug "Waiting for #{ @node_name } to respond to ping ..."
      break if dry_run || ping
    end
  end


  def wait_no_pong
    wait_loop do
      debug "Waiting for #{ @node_name } to stop responding to ping ..."
      break if dry_run || ( not ping )
    end
  end


  def wait_sshd
    wait_loop do
      debug "Waiting for sshd to start on #{ @node_name } ..."
      begin
        TCPSocket.open( @node_ip, 22 ) unless dry_run
        break
      rescue Errno::EHOSTUNREACH, Errno::ECONNREFUSED
        # do nothing
      end
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def wait_loop
    loop do
      yield
      sleep retry_interval
    end
  end


  def ping
    Ping.pingecho @node_ip
  end


  def block_until_match regexp, message
    raise "syslog is not set" unless @syslog
    wait_loop do
      debug message
      break if tail( regexp )
    end
  end


  def tail regexp
    while @syslog.gets
      return true if regexp.match( $_ )
    end
    false
  end


  def retry_interval
    @debug_options[ :retry_interval ] || DEFAULT_RETRY_INTERVAL
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
