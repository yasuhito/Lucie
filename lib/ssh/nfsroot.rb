require "lucie/utils"
require "ssh-home"


class SSH
  class Nfsroot
    include Lucie::Utils
    include SSHHome


    def initialize base_dir, debug_options
      @base_dir = base_dir
      @debug_options = debug_options
    end


    def setup_ssh_access public_key_path
      setup_sshd
      setup_ssh_home nfsroot_ssh_home_path
      install_public_key public_key_path
      chmod_authorized_keys
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


    def install_public_key public_key_path
      run "cp #{ public_key_path } #{ authorized_keys_path }", @debug_options
    end


    def chmod_authorized_keys
      run "chmod 0644 #{ authorized_keys_path }", @debug_options
    end


    def nfsroot_ssh_home_path
      path "root/.ssh"
    end


    def authorized_keys_path
      File.join nfsroot_ssh_home_path, "authorized_keys"
    end


    def path the_path
      File.join( @base_dir, the_path ).gsub( /\/+/, "/" )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
