require "lucie"
require "lucie/debug"
require "lucie/logger/null"
require "lucie/utils"
require "ssh/cp"
require "ssh/cp_r"
require "ssh/key-pair-generator"
require "ssh/nfsroot"
require "ssh/sh"
require "ssh/sh_a"
require "sub-process"


class SSH
  include Lucie::Debug
  include Lucie::Utils


  OPTIONS = "-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"


  def initialize debug_options = {}
    @debug_options = debug_options
    @key_pair_generator = KeyPairGenerator.new( @debug_options )
  end


  def maybe_generate_and_authorize_keypair
    @key_pair_generator.start
  end


  def setup_ssh_access_to nfsroot_dir
    Nfsroot.new( nfsroot_dir, @debug_options ).setup_ssh_access public_key_path
    info "ssh access to nfsroot configured."
  end


  def sh ip, command
    outputs = SubProcess::Shell.open( @debug_options ) do | shell |
      Sh.new( ip, command, private_key_path ).run( shell )
    end
    outputs.join "\n"
  end


  def sh_a ip, command, logger = Lucie::Logger::Null.new
    begin
      agent_pid = SubProcess::Shell.open( @debug_options ) do | shell |
        Sh_A.new( ip, command, private_key_path, @debug_options ).run( shell, logger )
      end
    ensure
      SubProcess::Shell.open( @debug_options ) do | shell |
        shell.exec "ssh-agent -k", { "SSH_AGENT_PID" => agent_pid }
      end
    end
  end


  def cp ip, from, to
    SubProcess::Shell.open( @debug_options ) do | shell |
      Cp.new( from, "#{ ip }:#{ to }", private_key_path, @debug_options ).run( shell )
    end
  end


  def cp_r ip, from, to
    SubProcess::Shell.open( @debug_options ) do | shell |
      Cp_r.new( from, "#{ ip }:#{ to }", private_key_path, @debug_options ).run( shell )
    end
  end


  def private_key_path
    @key_pair_generator.private_key_path
  end


  ##############################################################################
  private
  ##############################################################################


  def public_key_path
    @key_pair_generator.public_key_path
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
