require "lucie/logger/null"
require "ssh/copy-command"
require "ssh/cp"
require "ssh/cp_r"
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


  def sh ip, command, logger = Lucie::Logger::Null.new
    ShellCommand.new( Sh.new, @debug_options ).run( ip, command, logger )
  end


  def sh_a ip, command, logger = Lucie::Logger::Null.new
    ShellCommand.new( Sh_A.new, @debug_options ).run( ip, command, logger )
  end


  def cp from, to, logger = Lucie::Logger::Null.new
    CopyCommand.new( from, to, Cp.new, @debug_options ).run( logger )
  end


  def cp_r from, to, logger = Lucie::Logger::Null.new
    CopyCommand.new( from, to, Cp_r.new, @debug_options ).run( logger )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
