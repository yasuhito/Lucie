require "lucie"
require "lucie/io"
require "lucie/utils"
require "popen3/shell"


class SSH
  include Lucie::IO


  SSH_HOME = File.join( Lucie::ROOT, ".ssh" )
  PUBLIC_KEY = File.join( SSH_HOME, "id_rsa.pub" )
  PRIVATE_KEY = File.join( SSH_HOME, "id_rsa" )

  OPTIONS = %{-o "PasswordAuthentication no" -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" -o "LogLevel=ERROR"}


  attr_accessor :dry_run # :nodoc:
  attr_accessor :messenger # :nodoc:
  attr_accessor :verbose # :nodoc:


  def initialize options = {}, messenger = nil
    @verbose = options[ :verbose ]
    @dry_run = options[ :dry_run ]
    @messenger = messenger
  end


  def generate_keypair ssh_home = nil
    @ssh_home = ssh_home
    setup_local_ssh_home
    ssh_keygen
    update_authorized_keys
  end


  def setup_nfsroot path
    @nfsroot_directory = path
    setup_sshd
    setup_nfsroot_ssh_home
    install_public_key_to_nfsroot
    info "ssh access to nfsroot configured."
  end


  def sh ip, command
    output = ""
    real_command = %{ssh -i #{ PRIVATE_KEY } -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@#{ ip } "#{ command }"}
    Popen3::Shell.open do | shell |
      shell.on_stdout do | line |
        output << line
      end
      shell.on_failure do
        raise "command #{ command } failed on #{ ip }"
      end
      @messenger.puts real_command if @verbose
      shell.exec real_command unless @dry_run
    end
    output
  end


  def cp_r ip, from, to
    command = "scp -i #{ PRIVATE_KEY } -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r #{ from } root@#{ ip }:#{ to }"
    Popen3::Shell.open do | shell |
      @messenger.puts command if @verbose
      shell.exec command unless @dry_run
    end
  end


  ##############################################################################
  private
  ##############################################################################


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
      Lucie::Utils.mkdir_p nfsroot_ssh_home, { :verbose => @verbose, :dry_run => @dry_run }, @messenger
    end
    run "chmod 0700 #{ nfsroot_ssh_home }"
  end


  def install_public_key_to_nfsroot
    run "cp #{ public_key_path } #{ nfsroot_authorized_keys_path }"
    run "chmod 0644 #{ nfsroot_authorized_keys_path }"
  end


  def setup_local_ssh_home
    unless FileTest.directory?( ssh_home )
      Lucie::Utils.mkdir_p ssh_home, { :verbose => @verbose, :dry_run => @dry_run }, @messenger
    end
    run "chmod 0700 #{ ssh_home }"
  end


  def ssh_keygen
    unless FileTest.exists?( private_key_path ) and FileTest.exists?( private_key_path )
      run %{ssh-keygen -t rsa -N "" -f #{ private_key_path }}
    end
  end


  def update_authorized_keys
    return if authorized_keys.include?( public_key )
    authorize_public_key
  end


  def authorize_public_key
    run "cat #{ public_key_path } >> #{ authorized_keys_path }"
    run "chmod 0644 #{ authorized_keys_path }"
  end


  # keys #######################################################################


  def public_key
    IO.read( public_key_path ).chomp
  end


  def authorized_keys
    IO.read( authorized_keys_path ).split( "\n" ) rescue []
  end


  # targets ####################################################################


  def public_key_path
    File.join ssh_home, "id_rsa.pub"
  end


  def private_key_path
    File.join ssh_home, "id_rsa"
  end


  def ssh_home
    @ssh_home || SSH_HOME
  end


  def authorized_keys_path
    File.expand_path "~/.ssh/authorized_keys"
  end


  def nfsroot_authorized_keys_path
    File.join nfsroot_ssh_home, "authorized_keys"
  end


  def nfsroot_ssh_home
    nfsroot "root/.ssh"
  end


  def nfsroot path
    File.join( @nfsroot_directory, path ).gsub( /\/+/, "/" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
