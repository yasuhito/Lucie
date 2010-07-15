require "boot-sequence-tracker"
require "lucie/debug"
require "lucie/utils"
require "ssh"


#
# A node rebooter that initiates first/second/third reboot process.
#
#  sr = SuperReboot.new( node, syslog, logger )
#  sr.start_first_stage
#  sr.wait_manual_reboot
#  sr.start_second_stage
#  sr.reboot_to_finish_installation
#
class SuperReboot
  include Lucie::Debug
  include Lucie::Utils


  def initialize node, syslog, logger, debug_options = {}
    @node = node
    @node_name = node.name
    @syslog = syslog
    @logger = logger
    @debug_options = debug_options
    @ssh = SSH.new( @logger, @debug_options )
  end


  def start_first_stage script = nil, total_reboots = nil
    try_reboot script
    start_tracker reboot_sequence, total_reboots ? "(Reboot 1/#{ total_reboots }) " : ""
  end


  def wait_manual_reboot
    start_tracker manual_reboot_sequence
  end


  def start_second_stage total_reboots = nil
    run_ssh_swapoff
    run_ssh_reboot
    start_tracker local_boot_sequence, total_reboots ? "(Reboot 2/#{ total_reboots }) " : ""
  end


  def reboot_to_finish_installation total_reboots = nil
    run_ssh_reboot
    start_tracker local_boot_sequence, total_reboots ? "(Reboot 3/#{ total_reboots }) " : ""
  end


  ##############################################################################
  private
  ##############################################################################


  def reboot_sequence
    [ :wait_dhcpack, :wait_pxe ] + network_boot_sequence
  end


  def manual_reboot_sequence
    [ :wait_manual_reboot ] + network_boot_sequence
  end


  def network_boot_sequence
    [ :wait_dhcpack, :wait_nfsroot, :wait_pong, :wait_sshd ]
  end


  def local_boot_sequence
    [ :wait_dhcpack, :wait_pxe_localboot, :wait_pong, :wait_sshd ]
  end


  # Misc. ######################################################################


  def start_tracker sequence, prefix = nil
    tracker = BootSequenceTracker.new( @syslog, @node, @logger, @debug_options )
    sequence.each do | each |
      tracker.__send__ each, prefix
    end
  end


  def try_reboot script
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
    run command, @debug_options
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
