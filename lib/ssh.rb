require "lucie/logger/null"
require "ssh/cp"
require "ssh/cp_r"
require "ssh/key-pair-generator"
require "ssh/nfsroot"
require "ssh/sh"
require "ssh/sh_a"
require "sub-process"


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
    subprocess do | shell |
      Sh.new( ip, command, @debug_options ).run( shell, logger )
    end
  end


  def sh_a ip, command, logger = Lucie::Logger::Null.new
    begin
      agent_pid = subprocess do | shell |
        Sh_A.new( ip, command, @debug_options ).run( shell, logger )
      end
    ensure
      kill_ssh_agent agent_pid
    end
  end


  def cp from, to, logger = Lucie::Logger::Null.new
    subprocess do | shell |
      Cp.new( from, to, @debug_options ).run( shell, logger )
    end
  end


  def cp_r from, to, logger = Lucie::Logger::Null.new
    subprocess do | shell |
      Cp_r.new( from, to, @debug_options ).run( shell, logger )
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def kill_ssh_agent agent_pid
    subprocess do | shell |
      shell.exec "ssh-agent -k", { "SSH_AGENT_PID" => agent_pid }
    end
  end


  def subprocess &block
    SubProcess::Shell.open( @debug_options ) do | shell |
      block.call shell
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
