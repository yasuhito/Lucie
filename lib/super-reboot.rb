require "boot-sequence-tracker"
require "lucie/debug"
require "lucie/utils"
require "ssh"


class SuperReboot
  include Lucie::Debug
  include Lucie::Utils


  def initialize node, syslog, logger, debug_options = {}
    @node = node
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
    ssh_reboot
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
    return if rebooted_with( script )
    return if rebooted_via_ssh
    raise "failed to super-reboot"
  end


  def rebooted_with script
    return false unless script
    command = "#{ script } #{ @node.name }"
    info "Executing '#{ command }' to reboot #{ @node.name } ..."
    begin
      run command, @debug_options, messenger
    rescue => e
      error "Reboot script '#{ command }' failed."
      return false
    end
    info "Succeeded in executing '#{ command }'. Now rebooting #{ @node.name } ..."
    true
  end


  def rebooted_via_ssh
    info "Rebooting #{ @node.name } via ssh ..."
    begin
      @ssh.sh @node.name, "shutdown -r now"
    rescue
      error "Rebooting #{ @node.name } via ssh failed."
      return false
    end
    info "Succeeded in rebooting #{ @node.name } via ssh. Now rebooting ..."
    true
  end


  def ssh_reboot
    info "Rebooting #{ @node.name } via ssh ..."
    @ssh.sh @node.name, "swapoff -a"
    @ssh.sh @node.name, "shutdown -r now"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
