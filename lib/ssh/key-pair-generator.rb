require "lucie"
require "lucie/utils"


class SSH
  class KeyPairGenerator
    include Lucie::Utils


    def initialize debug_options
      @debug_options = debug_options
    end


    def start
      setup_local_ssh_home
      unless keypair_exists?
        cleanup_old_keys
        ssh_keygen
      end
      maybe_authorize_public_key
      maybe_chmod_authorized_keys
    end


    def setup_ssh_home target
      mkdir_p target, @debug_options unless FileTest.directory?( target )
      run "chmod 0700 #{ target }", @debug_options
    end


    def authorized_keys_path
      File.join local_ssh_home, "authorized_keys"
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


    ############################################################################
    private
    ############################################################################


    def setup_local_ssh_home
      setup_ssh_home local_ssh_home
    end


    def keypair_exists?
      FileTest.exists?( public_key_path ) and FileTest.exists?( private_key_path )
    end


    def cleanup_old_keys
      run "rm -f #{ public_key_path }", @debug_options
      run "rm -f #{ private_key_path }", @debug_options
    end


    def ssh_keygen
      run %{ssh-keygen -t rsa -N "" -f #{ private_key_path }}, @debug_options
    end


    def maybe_authorize_public_key
      unless authorized?
        run "cat #{ public_key_path } >> #{ authorized_keys_path }", @debug_options
      end
    end


    def maybe_chmod_authorized_keys
      unless authorized_keys_has_valid_permission?
        run "chmod 0644 #{ authorized_keys_path }", @debug_options
      end
    end


    def authorized_keys_has_valid_permission?
      return if @debug_options[ :dry_run ]
      File.stat( authorized_keys_path ).mode.to_s( 8 ) == "100644"
    end


    def authorized_keys
      IO.read( authorized_keys_path ).split( "\n" )
    end


    def authorized?
      return false unless FileTest.exists?( authorized_keys_path )
      authorized_keys.include?( public_key ) unless @debug_options[ :dry_run ]
    end


    def local_ssh_home
      if FileTest.exists?( lucie_public_key_path ) and FileTest.exists?( lucie_private_key_path )
        lucie_ssh_home
      else
        ssh_home
      end
    end


    def ssh_home
      File.join @debug_options[ :home ] || File.expand_path( "~" ), ".ssh"
    end


    def lucie_ssh_home
      File.join @debug_options[ :lucie_home ] || Lucie::ROOT, ".ssh"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
