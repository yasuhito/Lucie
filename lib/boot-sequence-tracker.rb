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
    @node = node
    @dhcpd_re = DhcpdRE.new( @node )
    @nfsd_re = NfsdRE.new( @node )
    @tftpd_re = TftpdRE.new( @node )
    @logger = logger
    @debug_options = debug_options
  end


  def syslog= io
    @syslog = io
    @syslog.seek 0, IO::SEEK_END unless dry_run
  end


  def wait_pxe
    block_until_match @tftpd_re.pxelinux, "Waiting for #{ name } to request PXE boot loader ..."
    block_until_match @tftpd_re.pxelinux_cfg, "Waiting for #{ name } to request PXE boot loader configuration file ..."
    block_until_match @tftpd_re.kernel, "Waiting for #{ name } to request Lucie kernel ..."
  end


  def wait_manual_reboot
    block_until_match @tftpd_re.pxelinux, "Please reboot #{ name } manually."
    block_until_match @tftpd_re.pxelinux_cfg, "Waiting for #{ name } to request PXE boot loader configuration file ..."
    block_until_match @tftpd_re.kernel, "Waiting for #{ name } to request Lucie kernel ..."
  end


  def wait_pxe_localboot
    block_until_match @tftpd_re.pxelinux, "Waiting for #{ name } to request PXE boot loader ..."
    block_until_match @tftpd_re.pxelinux_cfg, "Waiting for #{ name } to request PXE boot loader configuration file ..."
  end


  def wait_dhcpack
    block_until_match @dhcpd_re.discover, "Waiting for #{ name } to send DHCPDISCOVER ..."
    block_until_match @dhcpd_re.offer, "Waiting for #{ name } to receive DHCPOFFER ..."
    block_until_match @dhcpd_re.request, "Waiting for #{ name } to send DHCPREQUEST ..."
    block_until_match @dhcpd_re.ack, "Waiting for #{ name } to receive DHCPACK ..."
  end


  def wait_nfsroot
    block_until_match @nfsd_re.mount, "Waiting for #{ name } to mount nfsroot ..."
  end


  def wait_pong
    wait_loop do
      debug "Waiting for #{ name } to respond to ping ..."
      dry_run || ping
    end
  end


  def wait_no_pong
    wait_loop do
      debug "Waiting for #{ name } to stop responding to ping ..."
      dry_run || ( not ping )
    end
  end


  def wait_sshd
    wait_loop do
      debug "Waiting for sshd to start on #{ name } ..."
      begin
        TCPSocket.open( ip, 22 ) unless dry_run
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
    Ping.pingecho ip
  end


  def block_until_match regexp, message
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


  def name
    @node.name
  end


  def ip
    @node.ip_address
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
