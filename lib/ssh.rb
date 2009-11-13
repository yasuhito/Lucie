require "lucie"
require "lucie/io"
require "lucie/logger/null"
require "lucie/utils"
require "popen3"


class SSH
  include Lucie::IO


  OPTIONS = "-o PasswordAuthentication=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR"


  attr_accessor :dry_run # :nodoc:
  attr_accessor :messenger # :nodoc:
  attr_accessor :verbose # :nodoc:


  def self.private_key
    lucie_priv_key = File.join( Lucie::ROOT, ".ssh", "id_rsa" )
    user_priv_key = File.expand_path( File.join( "~", ".ssh", "id_rsa" ) )
    if FileTest.exists?( lucie_priv_key )
      lucie_priv_key
    elsif FileTest.exists?( user_priv_key )
      user_priv_key
    else
      raise "SSH private key not found."
    end
  end


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


  def setup_ssh_access_to path
    @nfsroot_directory = path
    setup_sshd
    setup_nfsroot_ssh_home
    install_public_key_to_nfsroot
    info "ssh access to nfsroot configured."
  end


  def sh ip, command
    output = []
    real_command = %{ssh -i #{ SSH.private_key } #{ OPTIONS } root@#{ ip } "#{ command }"}
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        output << line
      end
      shell.on_failure do
        raise "command #{ command } failed on #{ ip }"
      end
      debug real_command if @verbose || @dry_run
      shell.exec real_command unless @dry_run
    end
    output.join "\n"
  end


  def sh_a ip, command, logger = Lucie::Logger::Null.new
    agent_pid = nil
    begin
      real_command = ssh_agent( %{ssh -A -i #{ SSH.private_key } #{ OPTIONS } root@#{ ip } "#{ command }"} )
      Popen3::Shell.open do | shell |
        shell.on_stdout do | line |
          agent_pid = $1 if /^Agent pid (\d+)/=~ line
          $stdout.puts line
          logger.debug line
        end
        shell.on_stderr do | line |
          $stderr.puts line
          logger.debug line
        end
        shell.on_failure do
          raise "command #{ command } failed on #{ ip }"
        end
        logger.debug real_command
        debug real_command if @verbose || @dry_run
        shell.exec real_command unless @dry_run
      end
    ensure
      Popen3::Shell.open do | shell |
        shell.exec "ssh-agent -k", { "SSH_AGENT_PID" => agent_pid } unless @dry_run
      end
    end
  end


  def cp ip, from, to
    command = "scp -i #{ SSH.private_key } -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no #{ from } root@#{ ip }:#{ to }"
    Popen3::Shell.open do | shell |
      debug command if @verbose
      shell.exec command unless @dry_run
    end
  end


  def cp_r ip, from, to
    command = "scp -i #{ SSH.private_key } -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r #{ from } root@#{ ip }:#{ to }"
    Popen3::Shell.open do | shell |
      debug command if @verbose
      shell.exec command unless @dry_run
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def ssh_agent command
    "eval `ssh-agent`; ssh-add #{ SSH.private_key }; #{ command }"
  end


  def run command
    Lucie::Utils.run command, { :verbose => @verbose, :dry_run => @dry_run }, @messenger      
  end


  # tasks ######################################################################


  def setup_sshd
    run <<-COMMANDS
ruby -pi -e 'gsub( /PermitRootLogin no/, "PermitRootLogin yes" )' #{ nfsroot( "/etc/ssh/sshd_config" ) }
ruby -pi -e 'gsub( /.*PasswordAuthentication.*/, "PasswordAuthentication no" )' #{ nfsroot( "/etc/ssh/sshd_config" ) }
echo "UseDNS no" >> #{ nfsroot( "/etc/ssh/sshd_config" ) }
COMMANDS
  end


  def setup_nfsroot_ssh_home
    unless FileTest.directory?( nfsroot_ssh_home )
      Lucie::Utils.mkdir_p nfsroot_ssh_home, @debug_options
    end
    run "chmod 0700 #{ nfsroot_ssh_home }"
  end


  def install_public_key_to_nfsroot
    run "cp #{ public_key_path } #{ nfsroot_authorized_keys_path }"
    run "chmod 0644 #{ nfsroot_authorized_keys_path }"
  end


  def setup_local_ssh_home
    unless FileTest.directory?( local_ssh_home )
      Lucie::Utils.mkdir_p local_ssh_home, @debug_options
    end
    run "chmod 0700 #{ local_ssh_home }"
  end


  def ssh_keygen
    if ( not FileTest.exists?( public_key_path ) ) or ( not FileTest.exists?( private_key_path ) )
      run "rm -f #{ public_key_path }"
      run "rm -f #{ private_key_path }"
      run %{ssh-keygen -t rsa -N "" -f #{ private_key_path }}
    end
  end


  def update_authorized_keys
    return if authorized?
    authorize_public_key
  end


  def authorized?
    return false unless FileTest.exists?( authorized_keys_path )
    authorized_keys.include?( public_key ) unless @debug_options[ :dry_run ]
  end


  def authorize_public_key
    run "cat #{ public_key_path } >> #{ authorized_keys_path }"
    run "chmod 0644 #{ authorized_keys_path }"
  end


  # public and private key paths ###############################################


  def public_key
    IO.read( public_key_path ).chomp
  end


  def public_key_path
    File.join local_ssh_home, "id_rsa.pub"
  end


  def private_key_path
    File.join local_ssh_home, "id_rsa"
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


  def nfsroot_ssh_home
    nfsroot "root/.ssh"
  end


  def nfsroot path
    File.join( @nfsroot_directory, path ).gsub( /\/+/, "/" )
  end


  # authorized keys ############################################################


  def authorized_keys
    IO.read( authorized_keys_path ).split( "\n" )
  end


  def authorized_keys_path
    File.join local_ssh_home, "authorized_keys"
  end


  def nfsroot_authorized_keys_path
    File.join nfsroot_ssh_home, "authorized_keys"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
