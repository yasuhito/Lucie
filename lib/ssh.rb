require "lucie"
require "lucie/debug"
require "lucie/logger/null"
require "lucie/utils"
require "sub-process"


class SSH
  include Lucie::Debug


  OPTIONS = "-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"


  attr_accessor :dry_run # :nodoc:
  attr_accessor :messenger # :nodoc:
  attr_accessor :verbose # :nodoc:


  def initialize debug_options = {}
    @debug_options = debug_options
    @home = @debug_options[ :home ] || File.expand_path( "~" )
    @lucie_home = @debug_options[ :lucie_home ] || Lucie::ROOT
    @verbose = @debug_options[ :verbose ]
    @dry_run = @debug_options[ :dry_run ]
    @messenger = @debug_options[ :messenger ]
  end


  def maybe_generate_and_authorize_keypair
    setup_local_ssh_home
    ssh_keygen
    update_authorized_keys
  end


  def setup_ssh_access_to nfsroot_dir
    setup_sshd_on nfsroot_dir
    setup_ssh_home_on nfsroot_dir
    install_public_key_to nfsroot_dir
    info "ssh access to nfsroot configured."
  end


  def sh ip, command
    output = []
    real_command = %{ssh -i #{ private_key_path } #{ OPTIONS } root@#{ ip } "#{ command }"}
    SubProcess::Shell.open do | shell |
      shell.on_stdout do | line |
        output << line
      end
      shell.on_failure do
        raise "command #{ command } failed on #{ ip }"
      end
      debug real_command
      shell.exec real_command unless @dry_run
    end
    output.join "\n"
  end


  def sh_a ip, command, logger = Lucie::Logger::Null.new
    agent_pid = nil
    begin
      real_command = ssh_agent( %{ssh -A -i #{ private_key_path } #{ OPTIONS } root@#{ ip } "#{ command }"} )
      SubProcess::Shell.open do | shell |
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
        debug real_command
        shell.exec real_command unless @dry_run
      end
    ensure
      SubProcess::Shell.open do | shell |
        shell.exec "ssh-agent -k", { "SSH_AGENT_PID" => agent_pid } unless @dry_run
      end
    end
  end


  def cp ip, from, to
    popen3_shell "scp -i #{ private_key_path } #{ OPTIONS } #{ from } root@#{ ip }:#{ to }"
  end


  def cp_r ip, from, to
    popen3_shell "scp -i #{ private_key_path } #{ OPTIONS } -r #{ from } root@#{ ip }:#{ to }"
  end


  def private_key_path
    File.join local_ssh_home, "id_rsa"
  end


  ##############################################################################
  private
  ##############################################################################


  def popen3_shell command
    SubProcess::Shell.open do | shell |
      debug command
      shell.exec command unless @dry_run
    end
  end


  def ssh_agent command
    "eval `ssh-agent`; ssh-add #{ private_key_path }; #{ command }"
  end


  def run command
    Lucie::Utils.run command, { :verbose => @verbose, :dry_run => @dry_run }, @messenger      
  end


  def setup_sshd_on nfsroot_dir
    run <<-COMMANDS
ruby -pi -e 'gsub( /PermitRootLogin no/, "PermitRootLogin yes" )' #{ nfsroot( nfsroot_dir, "/etc/ssh/sshd_config" ) }
ruby -pi -e 'gsub( /.*PasswordAuthentication.*/, "PasswordAuthentication no" )' #{ nfsroot( nfsroot_dir, "/etc/ssh/sshd_config" ) }
echo "UseDNS no" >> #{ nfsroot( nfsroot_dir, "/etc/ssh/sshd_config" ) }
COMMANDS
  end


  def install_public_key_to nfsroot_dir
    target = nfsroot_authorized_keys_path( nfsroot_dir )
    run "cp #{ public_key_path } #{ target }"
    run "chmod 0644 #{ target }"
  end


  def ssh_keygen
    if ( not FileTest.exists?( public_key_path ) ) or ( not FileTest.exists?( private_key_path ) )
      run "rm -f #{ public_key_path }"
      run "rm -f #{ private_key_path }"
      run %{ssh-keygen -t rsa -N "" -f #{ private_key_path }}
    end
  end


  # key authorization ##########################################################


  def authorized?
    return false unless FileTest.exists?( authorized_keys_path )
    authorized_keys.include?( public_key ) unless @debug_options[ :dry_run ]
  end


  def update_authorized_keys
    return if authorized?
    authorize_public_key
  end


  def authorize_public_key
    run "cat #{ public_key_path } >> #{ authorized_keys_path }"
    run "chmod 0644 #{ authorized_keys_path }"
  end


  def authorized_keys
    IO.read( authorized_keys_path ).split( "\n" )
  end


  def authorized_keys_path
    File.join local_ssh_home, "authorized_keys"
  end


  def nfsroot_authorized_keys_path base_dir
    File.join nfsroot_ssh_home( base_dir ), "authorized_keys"
  end


  # .ssh directory #############################################################


  def setup_local_ssh_home
    setup_ssh_home local_ssh_home
  end


  def setup_ssh_home_on nfsroot_dir
    setup_ssh_home nfsroot_ssh_home( nfsroot_dir )
  end


  def setup_ssh_home target
    unless FileTest.directory?( target )
      Lucie::Utils.mkdir_p target, @debug_options
    end
    run "chmod 0700 #{ target }"
  end


  # public and private key paths ###############################################


  def public_key
    IO.read( public_key_path ).chomp
  end


  def public_key_path
    File.join local_ssh_home, "id_rsa.pub"
  end


  def lucie_public_key_path
    File.join lucie_ssh_home, "id_rsa.pub"
  end


  def lucie_private_key_path
    File.join lucie_ssh_home, "id_rsa"
  end


  # ssh paths ##################################################################


  def ssh_home
    File.join @home, ".ssh"
  end


  def lucie_ssh_home
    File.join @lucie_home, ".ssh"
  end


  def local_ssh_home
    if FileTest.exists?( lucie_public_key_path ) and FileTest.exists?( lucie_private_key_path )
      lucie_ssh_home
    else
      ssh_home
    end
  end


  def nfsroot_ssh_home nfsroot_dir
    nfsroot nfsroot_dir, "root/.ssh"
  end


  def nfsroot base_dir, path
    File.join( base_dir, path ).gsub( /\/+/, "/" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
