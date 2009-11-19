require "lucie"
require "lucie/debug"
require "lucie/utils"
require "ssh-home"


class SSH
  class KeyPairGenerator
    include Lucie::Debug
    include Lucie::Utils
    include SSHHome


    def initialize debug_options
      @debug_options = debug_options
    end


    def start
      setup_ssh_home ssh_home
      unless keypair_exists?
        cleanup_old_keys
        ssh_keygen
      end
      maybe_authorize_public_key
      maybe_chmod_authorized_keys
    end


    ############################################################################
    private
    ############################################################################


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
      run "chmod 0644 #{ authorized_keys_path }", @debug_options unless authorized_keys_has_valid_permission?
    end


    def authorized_keys_has_valid_permission?
      dry_run || File.stat( authorized_keys_path ).mode.to_s( 8 ) == "100644"
    end


    def authorized?
      FileTest.exists?( authorized_keys_path ) and authorized_keys.include?( public_key )
    end


    def authorized_keys
      dry_run ? [] : IO.read( authorized_keys_path ).split( "\n" )
    end


    def public_key
      dry_run ? "" : IO.read( public_key_path ).chomp
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
