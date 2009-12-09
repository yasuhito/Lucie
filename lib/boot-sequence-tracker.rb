require "boot-sequence-tracker/dhcpd-re"
require "boot-sequence-tracker/nfsd-re"
require "boot-sequence-tracker/tftpd-re"
require "lucie/debug"
require "ping"
require "socket"


class BootSequenceTracker
  include Lucie::Debug
  include DhcpdRE
  include NfsdRE
  include TftpdRE


  DEFAULT_RETRY_INTERVAL = 30


  def initialize node, logger, debug_options = {}
    @node = node
    @node_name = node.name
    @node_ip = node.ip_address
    @logger = logger
    @debug_options = debug_options
  end


  def syslog= io
    @syslog = io
    @syslog.seek 0, IO::SEEK_END unless dry_run
  end


  def wait_pxe
    wait pxe_regexps( "Waiting for #{ @node_name } to request PXE boot loader ..." )
  end


  def wait_manual_reboot
    wait pxe_regexps( "Please reboot #{ @node_name } manually." )
  end


  def wait_pxe_localboot
    wait pxe_localboot_regexps
  end


  def wait_dhcpack
    wait dhcp_regexps
  end


  def wait_nfsroot
    wait nfsroot_regexps
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
      debug "Waiting for #{ @node_name } to start sshd ..."
      begin
        TCPSocket.open( @node_ip, 22 ) unless dry_run
        break
      rescue Errno::EHOSTUNREACH, Errno::ECONNREFUSED
        # do nothing
        nil
      end
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def wait log_RE
    log_RE.each do | re, message |
      block_until_match re, message
    end
  end


  def pxe_regexps boot_loader_message = "Waiting for #{ @node_name } to request PXE boot loader ..."
    [ [ pxelinux_RE( @node ), boot_loader_message ],
      [ pxelinux_cfg_RE( @node ), "Waiting for #{ @node_name } to request PXE boot loader configuration file ..." ],
      [ pxekernel_RE( @node ), "Waiting for #{ @node_name } to request Lucie kernel ..." ] ]
  end


  def pxe_localboot_regexps
    [ [ pxelinux_RE( @node ), "Waiting for #{ @node_name } to request PXE boot loader ..." ],
      [ pxelinux_cfg_RE( @node ), "Waiting for #{ @node_name } to request PXE boot loader configuration file ..." ] ]
  end


  def dhcp_regexps
    [ [ dhcpdiscover_RE( @node ), "Waiting for #{ @node_name } to send DHCPDISCOVER ..." ],
      [ dhcpoffer_RE( @node ), "Waiting for #{ @node_name } to receive DHCPOFFER ..." ],
      [ dhcprequest_RE( @node ), "Waiting for #{ @node_name } to send DHCPREQUEST ..." ],
      [ dhcpack_RE( @node ), "Waiting for #{ @node_name } to receive DHCPACK ..." ] ]
  end


  def nfsroot_regexps
    [ [ nfsroot_mount_RE( @node ), "Waiting for #{ @node_name } to mount nfsroot ..." ] ]
  end


  # Misc #######################################################################


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
