require "lucie"
require "lucie/debug"
require "lucie/logger/null"
require "lucie/utils"
require "ssh/key-pair-generator"
require "ssh/nfsroot"
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
    Nfsroot.new( nfsroot_dir, @debug_options ).setup_ssh_access public_key_path
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


  def public_key_path
    @key_pair_generator.public_key_path
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
