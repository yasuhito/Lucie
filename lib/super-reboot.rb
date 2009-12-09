require "boot-sequence-tracker"
require "lucie/debug"
require "lucie/utils"
require "ssh"


class SuperReboot
  include Lucie::Debug
  include Lucie::Utils


  def initialize debug_options = {}
    @debug_options = debug_options
    @ssh = SSH.new( @debug_options )
  end


  def start_first_stage node, syslog, logger, script = nil
    start_tracker( syslog, node, logger ) do | tracker |
      reboot_and_wait node, tracker, logger, script
      tracker.wait_pxe
      tracker.wait_dhcpack
      tracker.wait_nfsroot
      tracker.wait_pong
      tracker.wait_sshd
    end
  end


  def wait_manual_reboot node, syslog, logger
    start_tracker( syslog, node, logger ) do | tracker |
      tracker.wait_manual_reboot
      tracker.wait_dhcpack
      tracker.wait_nfsroot
      tracker.wait_pong
      tracker.wait_sshd
    end
  end


  def start_second_stage node, syslog, logger
    start_tracker( syslog, node, logger ) do | tracker |
      ssh_reboot node
      tracker.wait_dhcpack
      tracker.wait_pxe_localboot
      tracker.wait_pong
      tracker.wait_sshd
    end
  end


  def reboot_to_finish_installation node, syslog, logger
    start_tracker( syslog, node, logger ) do | tracker |
      ssh_reboot node
      tracker.wait_dhcpack
      tracker.wait_pxe_localboot
      tracker.wait_pong
      tracker.wait_sshd
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def reboot_and_wait node, tracker, logger, script
    reboot node, script
    tracker.wait_dhcpack
  end


  def reboot node, script
    return if script and rebooted_with_script?( node.name, script )
    return if rebooted_via_ssh?( node.name )
    raise "failed to super-reboot"
  end


  def ssh_reboot node
    info "Rebooting #{ node.name } via ssh ..."
    @ssh.sh node.name, "swapoff -a"
    @ssh.sh node.name, "shutdown -r now"
  end


  def start_tracker syslog, node, logger
    yield BootSequenceTracker.new( syslog, node, logger, @debug_options )
  end


  def rebooted_with_script? node_name, script
    command = "#{ script } #{ node_name }"
    info "Executing '#{ command }' to reboot #{ node_name } ..."
    begin
      run command, @debug_options, messenger
    rescue => e
      error "Reboot script '#{ command }' failed."
      return false
    end
    info "Succeeded in executing '#{ command }'. Now rebooting #{ node_name } ..."
    true
  end


  def rebooted_via_ssh? node_name
    info "Rebooting #{ node_name } via ssh ..."
    begin
      @ssh.sh node_name, "shutdown -r now"
    rescue
      error "Rebooting #{ node_name } via ssh failed."
      return false
    end
    info "Succeeded in rebooting #{ node_name } via ssh. Now rebooting ..."
    true
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
