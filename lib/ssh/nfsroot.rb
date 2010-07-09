require "lucie/debug"
require "lucie/utils"
require "ssh/home"
require "ssh/path"


#
# Setups ssh access to nfsroot.
#
class SSH::Nfsroot # :nodoc:
  include Lucie::Debug
  include Lucie::Utils
  include SSH::Path


  def initialize base_dir, debug_options
    @base_dir = base_dir
    @ssh_home = SSH::Home.new( nfsroot_ssh_home, debug_options )
    @debug_options = debug_options
  end


  def setup_ssh_access
    setup_sshd
    setup_ssh_home
    info "ssh access to nfsroot configured.\n"
  end


  ############################################################################
  private
  ############################################################################


  def setup_sshd
    sshd_config = path( "/etc/ssh/sshd_config" )
    run <<-COMMANDS, @debug_options
ruby -pi -e 'gsub( /PermitRootLogin no/, "PermitRootLogin yes" )' #{ sshd_config }
ruby -pi -e 'gsub( /.*PasswordAuthentication.*/, "PasswordAuthentication no" )' #{ sshd_config }
echo "UseDNS no" >> #{ sshd_config }
COMMANDS
  end


  def setup_ssh_home
    @ssh_home.setup
  end


  def nfsroot_ssh_home
    path "root/.ssh"
  end


  def path the_path
    File.join( @base_dir, the_path ).gsub( /\/+/, "/" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
