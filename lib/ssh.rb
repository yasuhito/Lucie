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


  #
  # Generates a new SSH-key pair if need be.
  #
  def maybe_generate_keypair
    KeyPairGenerator.new( @debug_options ).start
  end


  #
  # Sets up password-less SSH access to nfsroot
  #
  def setup_ssh_access_to nfsroot_dir
    Nfsroot.new( nfsroot_dir, @debug_options ).setup_ssh_access
  end


  #
  # The following command line:
  #   % ssh root@macbook
  #
  # is equivalent to:
  #   ssh = SSH.new
  #   ssh.login "macbook"
  #
  def login host_name
    LoginProcess.new( host_name, @debug_options ).run
  end


  #
  # The following command line:
  #   % ssh root@macbook "ls -1 /tmp"
  #
  # is equivalent to:
  #   ssh = SSH.new
  #   ssh.sh "macbook", "ls -1 /tmp"
  #
  def sh host_name, command_line
    @process = ShProcess.new( host_name, command_line, @logger, @debug_options )
    @process.run
  end


  #
  # Returns the output log of the previous :sh method.
  #
  #   ssh = SSH.new
  #   ssh.sh( "macbook", "ls -1 /tmp" ).output
  #     #=> "hoge.sh\nmymemo.txt\nyasuhito"
  #
  def output
    @process.output
  end


  #
  # The following command line:
  #   % ssh -A root@macbook "ls /root"
  #
  # is equivalent to:
  #   ssh = SSH.new
  #   ssh.sh_a "macbook", "ls /root"
  #
  def sh_a host_name, command_line
    ShaProcess.new( host_name, command_line, @logger, @debug_options ).run
  end


  #
  # The following command line:
  #   % scp ~/.ssh/id_rsa.pub macbook:~/tmp
  #
  # is equivalent to:
  #   ssh = SSH.new
  #   ssh.cp "~/.ssh/id_rsa.pub", "macbook:~/tmp"
  #
  def cp from, to
    ScpProcess.new( from, to, @logger, @debug_options ).run
  end


  #
  # The following command line:
  #   % scp -r ~/Movies macbook:~
  #
  # is equivalent to:
  #   ssh = SSH.new
  #   ssh.cp_r "~/Movies", "macbook:~"
  #
  def cp_r from, to
    ScprProcess.new( from, to, @logger, @debug_options ).run
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
