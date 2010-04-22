require "lucie/debug"
require "lucie/utils"
require "ssh/home"
require "ssh/path"


class SSH
  #
  # Generates a new ssh keypair and authorizes its public key if need be.
  #
  class KeyPairGenerator
    include Lucie::Debug
    include Lucie::Utils
    include Path


    def initialize debug_options = {}
      @debug_options = debug_options
    end


    def start
      begin
        Home.new( ssh_home, @debug_options ).setup
      rescue
        maybe_cleanup_old_key_pair
        ssh_keygen
        retry unless dry_run
      end
    end


    ############################################################################
    private
    ############################################################################


    def maybe_cleanup_old_key_pair
      remove_if_exist user_public_key
      remove_if_exist user_private_key
    end


    def remove_if_exist file
      rm_f file, @debug_options if FileTest.exist?( file )
    end


    def ssh_keygen
      run %{ssh-keygen -t rsa -N "" -f #{ user_private_key }}, @debug_options
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
