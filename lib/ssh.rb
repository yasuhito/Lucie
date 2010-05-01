require "lucie/logger/null"
require "ssh/cp"
require "ssh/cp-recursive"
require "ssh/key-pair-generator"
require "ssh/nfsroot"
require "ssh/scp-process"
require "ssh/sh"
require "ssh/sh-agent"
require "ssh/ssh-process"


#
# Manages keypair and SSH connections to nodes.
#
class SSH
  OPTIONS = "-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"


  def initialize logger = nil, debug_options = {}
    @logger = logger || Lucie::Logger::Null.new
    @debug_options = debug_options
  end


  def maybe_generate_and_authorize_keypair
    KeyPairGenerator.new( @debug_options ).start
  end


  def setup_ssh_access_to nfsroot_dir
    Nfsroot.new( nfsroot_dir, @debug_options ).setup_ssh_access
  end


  def sh host_name, command_line
    SshProcess.new( host_name, command_line, Sh.new( @logger ), @debug_options ).run
  end


  def sh_a host_name, command_line
    SshProcess.new( host_name, command_line, ShAgent.new( @logger ), @debug_options ).run
  end


  def cp from, to
    ScpProcess.new( from, to, @logger, Cp.new, @debug_options ).run
  end


  def cp_r from, to
    ScpProcess.new( from, to, @logger, CpRecursive.new, @debug_options ).run
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
