require "lucie/utils"
require "reboot-watch-dog"
require "ssh"


class SuperReboot
  include Lucie::Utils


  def initialize html_logger, options = {}, messenger = nil
    @html_logger = html_logger
    @options = options
    @messenger = messenger
  end


  def start_first_stage node, syslog, logger, script = nil
    start_watchdog( node, syslog ) do | watchdog |
      reboot_and_wait node, watchdog, logger, script
      watchdog.wait_pxe
      watchdog.wait_dhcpack
      watchdog.wait_nfsroot
      watchdog.wait_pong
      watchdog.wait_sshd
    end
  end


  def start_second_stage node, syslog, logger
    log node, "Rebooting", logger
    start_watchdog( node, syslog ) do | watchdog |
      ssh_reboot node
      watchdog.wait_no_pong
      watchdog.wait_dhcpack
      watchdog.wait_pxe_localboot
      watchdog.wait_pong
      watchdog.wait_sshd
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def reboot_and_wait node, watchdog, logger, script
    begin
      log node, "Rebooting", logger
      reboot node, script
      watchdog.wait_no_pong
      watchdog.wait_dhcpack
    rescue
      log node, "Requesting manual reboot", logger
      wait_manual_reboot node, watchdog
    end
  end


  def wait_manual_reboot node, watchdog
    t = start_manual_reboot_prompt( node )
    watchdog.wait_dhcpack
    t.kill
  end


  def start_manual_reboot_prompt node
    Thread.start do
      loop do
        error "Please reboot #{ node.name } manually."
        sleep 2
      end
    end
  end


  def reboot node, script
    return if script and rebooted_with_script?( node.name, script )
    return if rebooted_via_ssh?( node.name )
    raise "failed to super-reboot"
  end


  def ssh_reboot node
    info "Rebooting #{ node.name } via ssh ..."
    run %{ssh -i #{ SSH::PRIVATE_KEY } #{ SSH::OPTIONS } root@#{ node.name } "swapoff -a"}, @options, @messenger
    run %{ssh -i #{ SSH::PRIVATE_KEY } #{ SSH::OPTIONS } root@#{ node.name } "shutdown -r now"}, @options, @messenger
  end


  def start_watchdog node, syslog
    watchdog = RebootWatchDog.new( node, @options, @messenger )
    watchdog.syslog = syslog
    yield watchdog
  end


  def rebooted_with_script? node_name, script
    command = "#{ script } #{ node_name }"
    info "Executing '#{ command }' to reboot #{ node_name } ..."
    begin
      run command, @options, @messenger
    rescue => e
      error "Reboot script '#{ command }' failed."
      return false
    end
    info "Succeeded in executing '#{ command }'. Now rebooting #{ node_name } ..."
    true
  end


  def rebooted_via_ssh? node_name
    info "Rebooting #{ node_name } via ssh ..."
    command = %{ssh -i #{ SSH::PRIVATE_KEY } #{ SSH::OPTIONS } root@#{ node_name } "reboot"}
    begin
      run command, @options, @messenger
    rescue
      error "Rebooting #{ node_name } via ssh failed."
      return false
    end
    info "Succeeded in rebooting #{ node_name } via ssh. Now rebooting ..."
    true
  end


  # Messaging ##################################################################


  def log node, message, logger
    @html_logger.update node, message
    logger.info message
  end


  def info message
    ( @messenger || $stdout ).puts message
  end


  def error message
    ( @messenger || $stderr ).puts message
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
