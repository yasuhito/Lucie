require "lucie"
require "lucie/debug"
require "lucie/logger/null"
require "lucie/utils"
require "ssh/key-pair-generator"
require "sub-process"


class SSH
  include Lucie::Debug
  include Lucie::Utils


  OPTIONS = "-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"


  attr_accessor :dry_run # :nodoc:
  attr_accessor :messenger # :nodoc:
  attr_accessor :verbose # :nodoc:


  def initialize debug_options = {}
    @debug_options = debug_options
    @key_pair_generator = KeyPairGenerator.new( @debug_options )
    @verbose = @debug_options[ :verbose ]
    @dry_run = @debug_options[ :dry_run ]
    @messenger = @debug_options[ :messenger ]
  end


  def maybe_generate_and_authorize_keypair
    @key_pair_generator.start
  end


  def setup_ssh_access_to nfsroot_dir
    setup_sshd_on nfsroot_dir
    setup_ssh_home_on nfsroot_dir
    install_public_key_to nfsroot_dir
    info "ssh access to nfsroot configured."
  end


  def sh ip, command
    SubProcess::Shell.open do | shell |
      ssh shell, ip, command
    end.join "\n"
  end


  def sh_a ip, command, logger = Lucie::Logger::Null.new
    begin
      agent_pid = SubProcess::Shell.open do | shell |
        ssh_a shell, ip, command, logger
      end
    ensure
      kill_ssh_agent agent_pid
    end
  end


  def cp ip, from, to
    popen3_shell "scp -i #{ private_key_path } #{ OPTIONS } #{ from } root@#{ ip }:#{ to }"
  end


  def cp_r ip, from, to
    popen3_shell "scp -i #{ private_key_path } #{ OPTIONS } -r #{ from } root@#{ ip }:#{ to }"
  end


  def private_key_path
    @key_pair_generator.private_key_path
  end


  ##############################################################################
  private
  ##############################################################################


  def ssh shell, ip, command
    output = []
    real_command = %{ssh -i #{ private_key_path } #{ OPTIONS } root@#{ ip } "#{ command }"}
    shell.on_stdout do | line | 
      output << line
    end
    shell.on_failure do
      raise "command #{ command } failed on #{ ip }"
    end
    exec_and_debug shell, real_command
    output
  end


  def ssh_a shell, ip, command, logger
    agent_pid = nil
    real_command = ssh_agent( %{ssh -A -i #{ private_key_path } #{ OPTIONS } root@#{ ip } "#{ command }"} )
    shell.on_stdout do | line |
      agent_pid = $1 if /^Agent pid (\d+)/=~ line
      stdout.puts line
      logger.debug line
    end
    shell.on_stderr do | line |
      stderr.puts line
      logger.debug line
    end
    shell.on_failure do
      raise "command #{ command } failed on #{ ip }"
    end
    logger.debug real_command
    exec_and_debug shell, real_command
    agent_pid
  end


  def exec_and_debug shell, command
    debug command
    shell.exec command unless @dry_run
  end


  def kill_ssh_agent pid
    SubProcess::Shell.open do | shell |
      shell.exec "ssh-agent -k", { "SSH_AGENT_PID" => pid } unless @dry_run
    end
  end


  def popen3_shell command
    SubProcess::Shell.open do | shell |
      debug command
      shell.exec command unless @dry_run
    end
  end


  def ssh_agent command
    "eval `ssh-agent`; ssh-add #{ private_key_path }; #{ command }"
  end


  def setup_sshd_on nfsroot_dir
    sshd_config = nfsroot( nfsroot_dir, "/etc/ssh/sshd_config" )
    run <<-COMMANDS, @debug_options
ruby -pi -e 'gsub( /PermitRootLogin no/, "PermitRootLogin yes" )' #{ sshd_config }
ruby -pi -e 'gsub( /.*PasswordAuthentication.*/, "PasswordAuthentication no" )' #{ sshd_config }
echo "UseDNS no" >> #{ sshd_config }
COMMANDS
  end


  def install_public_key_to nfsroot_dir
    target = nfsroot_authorized_keys_path( nfsroot_dir )
    run "cp #{ public_key_path } #{ target }", @debug_options
    run "chmod 0644 #{ target }", @debug_options
  end


  # key authorization ##########################################################


  def authorized_keys_path
    @key_pair_generator.authorized_keys_path
  end


  def authorized_keys
    IO.read( authorized_keys_path ).split( "\n" )
  end


  def nfsroot_authorized_keys_path base_dir
    File.join nfsroot_ssh_home( base_dir ), "authorized_keys"
  end


  # .ssh directory #############################################################


  def setup_ssh_home_on nfsroot_dir
    @key_pair_generator.setup_ssh_home nfsroot_ssh_home( nfsroot_dir )
  end


  # public and private key paths ###############################################


  def public_key
    IO.read( public_key_path ).chomp
  end


  # ssh paths ##################################################################


  def nfsroot_ssh_home nfsroot_dir
    nfsroot nfsroot_dir, "root/.ssh"
  end


  def nfsroot base_dir, path
    File.join( base_dir, path ).gsub( /\/+/, "/" )
  end


  def public_key_path
    @key_pair_generator.public_key_path
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
