require "lucie/logger/null"


#
# Manages keypair and SSH connections to nodes.
#
class SSH
  require "ssh/key-pair-generator"
  require "ssh/login-process"
  require "ssh/nfsroot"
  require "ssh/scp-process"
  require "ssh/scpr-process"
  require "ssh/sh-process"
  require "ssh/sha-process"


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


  def login host_name
    LoginProcess.new( host_name, @debug_options ).run
  end


  def sh host_name, command_line
    @process = ShProcess.new( host_name, command_line, @logger, @debug_options )
    @process.run
  end


  def sh_a host_name, command_line
    ShaProcess.new( host_name, command_line, @logger, @debug_options ).run
  end


  def cp from, to
    ScpProcess.new( from, to, @logger, @debug_options ).run
  end


  def cp_r from, to
    ScprProcess.new( from, to, @logger, @debug_options ).run
  end


  def output
    @process.output
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
