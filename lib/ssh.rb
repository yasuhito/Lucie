require "lucie/logger/null"
require "ssh/copy-command"
require "ssh/cp"
require "ssh/cp-recursive"
require "ssh/key-pair-generator"
require "ssh/nfsroot"
require "ssh/sh"
require "ssh/sh_a"
require "ssh/shell-command"


class SSH
  OPTIONS = "-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"


  def initialize debug_options = {}
    @debug_options = debug_options
  end


  def maybe_generate_and_authorize_keypair
    KeyPairGenerator.new( @debug_options ).start
  end


  def setup_ssh_access_to nfsroot_dir
    Nfsroot.new( nfsroot_dir, @debug_options ).setup_ssh_access
  end


  def sh ip, command_line, logger = Lucie::Logger::Null.new
    ShellCommand.new( ip, command_line, Sh.new( logger ), @debug_options ).run
  end


  def sh_a ip, command_line, logger = Lucie::Logger::Null.new
    ShellCommand.new( ip, command_line, Sh_A.new( logger ), @debug_options ).run
  end


  def cp from, to, logger = Lucie::Logger::Null.new
    CopyCommand.new( from, to, Cp.new, logger, @debug_options ).run
  end


  def cp_r from, to, logger = Lucie::Logger::Null.new
    CopyCommand.new( from, to, CpRecursive.new, logger, @debug_options ).run
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
