require "lucie/logger"


class SSH
  require "ssh/home"
  require "ssh/path"

  require "ssh/key-pair-generator"
  require "ssh/login-process"
  require "ssh/nfsroot"
  require "ssh/scp-process"
  require "ssh/scpr-process"
  require "ssh/sh-process"
  require "ssh/sha-process"


  OPTIONS = "-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"


  #
  # Creates a new ssh client. The following options are available:
  # 
  # <tt>:logger</tt>:: Save logs with the specified logger [Lucie::Logger::Null]
  # <tt>:verbose</tt>:: Be verbose [nil] 
  # <tt>:dry_run</tt>:: Print the commands that would be executed, but do not execute them. [nil]
  #
  # Usage:
  #
  #   # New ssh client
  #   ssh = SSH.new
  #
  #   # New ssh client, with logging
  #   logger = Lucie::Logger::Installer.new
  #   ssh = SSH.new( :logger => logger )
  #
  #   # New ssh client, with logging, verbose mode.
  #   ssh = SSH.new( :logger => logger, :verbose => true )
  #
  #   # New ssh client, dry-run mode.
  #   ssh = SSH.new( :dry_run => true )
  #
  def initialize debug_options = {}
    @debug_options = { :logger => Lucie::Logger::Null.new }.merge( debug_options )
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
    @process = ShProcess.new( host_name, command_line, logger, @debug_options )
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
    ShaProcess.new( host_name, command_line, logger, @debug_options ).run
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
    ScpProcess.new( from, to, logger, @debug_options ).run
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
    ScprProcess.new( from, to, logger, @debug_options ).run
  end


  ##############################################################################
  private
  ##############################################################################


  def logger
    @debug_options[ :logger ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
