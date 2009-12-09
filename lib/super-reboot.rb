require "boot-sequence-tracker"
require "lucie/debug"
require "lucie/utils"
require "ssh"


class SuperReboot
  include Lucie::Debug
  include Lucie::Utils


  def initialize node, syslog, logger, debug_options = {}
    @node = node
    @node_name = node.name
    @syslog = syslog
    @logger = logger
    @debug_options = debug_options
    @ssh = SSH.new( @debug_options )
  end


  def start_first_stage script = nil
    reboot script
    start_tracker do | tracker |
      tracker.wait_dhcpack
      tracker.wait_pxe
      tracker.wait_dhcpack
      tracker.wait_nfsroot
      tracker.wait_pong
      tracker.wait_sshd
    end
  end


  def wait_manual_reboot
    start_tracker do | tracker |
      tracker.wait_manual_reboot
      tracker.wait_dhcpack
      tracker.wait_nfsroot
      tracker.wait_pong
      tracker.wait_sshd
    end
  end


  def start_second_stage
    run_ssh_swapoff
    run_ssh_reboot
    start_tracker do | tracker |
      tracker.wait_dhcpack
      tracker.wait_pxe_localboot
      tracker.wait_pong
      tracker.wait_sshd
    end
  end
  alias :reboot_to_finish_installation :start_second_stage


  ##############################################################################
  private
  ##############################################################################


  def start_tracker
    yield BootSequenceTracker.new( @syslog, @node, @logger, @debug_options )
  end


  def reboot script
    return if script && rebooted_with( script )
    return if rebooted_via_ssh
    raise "failed to super-reboot"
  end


  def rebooted_with script
    begin
      run_script_reboot script
    rescue
      error "Reboot script failed."
      return false
    end
    info "Reboot script succeeded. Now rebooting #{ @node_name } ..."
    true
  end


  def rebooted_via_ssh
    begin
      run_ssh_reboot
    rescue
      error "Rebooting #{ @node_name } via ssh failed."
      return false
    end
    info "Succeeded in rebooting #{ @node_name } via ssh. Now rebooting ..."
    true
  end


  def run_script_reboot script
    command = "#{ script } #{ @node_name }"
    info "Executing '#{ command }' to reboot #{ @node_name } ..."
    run command, @debug_options, messenger
  end


  def run_ssh_swapoff
    @ssh.sh @node_name, "swapoff -a"
  end


  def run_ssh_reboot
    info "Rebooting #{ @node_name } via ssh ..."
    @ssh.sh @node_name, "shutdown -r now"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
