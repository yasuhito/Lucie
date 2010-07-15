require "boot-sequence-tracker/syslog-re"
require "ping"
require "socket"


class BootSequenceTracker
  include SyslogRE


  DEFAULT_RETRY_INTERVAL = 1


  def initialize syslog, node, logger, debug_options = {}
    @syslog = syslog
    @node = node
    @node_name = node.name
    @node_ip = node.ip_address
    @logger = logger
    @debug_options = debug_options
    seek_end
  end


  def wait_pxe prefix = ""
    wait pxe_regexps( "#{ prefix }Waiting for #{ @node_name } to request PXE boot loader ...", prefix )
  end


  def wait_manual_reboot prefix = ""
    wait pxe_regexps( "#{ prefix }Please reboot #{ @node_name } manually.", prefix )
  end


  def wait_pxe_localboot prefix = ""
    wait pxe_localboot_regexps( prefix )
  end


  def wait_dhcpack prefix = ""
    wait dhcp_regexps( prefix )
  end


  def wait_nfsroot prefix = ""
    wait nfsroot_regexps( prefix )
  end


  def wait_pong prefix = ""
    wait_loop do
      debug "#{ prefix }Waiting for #{ @node_name } to respond to ping ..."
      break if dry_run || ping
    end
  end


  def wait_no_pong prefix = ""
    wait_loop do
      debug "#{ prefix }Waiting for #{ @node_name } to stop responding to ping ..."
      break if dry_run || ( not ping )
    end
  end


  def wait_sshd prefix = ""
    wait_loop do
      debug "#{ prefix }Waiting for #{ @node_name } to start sshd ..."
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


  def seek_end
    @syslog.seek 0, IO::SEEK_END unless dry_run
  end


  def wait log_re
    log_re.each do | re, message |
      block_until_match re, message
    end
  end


  def pxe_regexps boot_loader_message = "Waiting for #{ @node_name } to request PXE boot loader ...", prefix = nil
    [ [ tftp_linux_re( @node ), boot_loader_message ],
      [ tftp_linux_cfg_re( @node ), "#{ prefix }Waiting for #{ @node_name } to request PXE boot loader configuration file ..." ],
      [ tftp_kernel_re( @node ), "#{ prefix }Waiting for #{ @node_name } to request Lucie kernel ..." ] ]
  end


  def pxe_localboot_regexps prefix
    [ [ tftp_linux_re( @node ), "#{ prefix }Waiting for #{ @node_name } to request PXE boot loader ..." ],
      [ tftp_linux_cfg_re( @node ), "#{ prefix }Waiting for #{ @node_name } to request PXE boot loader configuration file ..." ] ]
  end


  def dhcp_regexps prefix
    [ [ dhcp_discover_re( @node ), "#{ prefix }Waiting for #{ @node_name } to send DHCPDISCOVER ..." ],
      [ dhcp_offer_re( @node ), "#{ prefix }Waiting for #{ @node_name } to receive DHCPOFFER ..." ],
      [ dhcp_request_re( @node ), "#{ prefix }Waiting for #{ @node_name } to send DHCPREQUEST ..." ],
      [ dhcp_ack_re( @node ), "#{ prefix }Waiting for #{ @node_name } to receive DHCPACK ..." ] ]
  end


  def nfsroot_regexps prefix
    [ [ nfs_mount_re( @node ), "#{ prefix }Waiting for #{ @node_name } to mount nfsroot ..." ] ]
  end


  # Misc #######################################################################


  def debug message
    @logger.debug message unless dry_run
    ( @debug_options[ :messenger ] || $stderr ).puts message
  end



  def dry_run
    @debug_options && @debug_options[ :dry_run ]
  end



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
