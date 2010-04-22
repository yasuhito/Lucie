# -*- coding: utf-8 -*-
require "lucie/debug"


class SSH
  module Path
    include Lucie::Debug


    PUBLIC_KEY_NAME = "id_rsa.pub"
    PRIVATE_KEY_NAME = "id_rsa"


    #--
    # [FIXME] dryrun かどうかでの場合分け。authorized_keys では
    #         @ssh_home を見てるのでどっちかにすべき。
    #++ 
    def public_key
      base_dir = dry_run ? user_ssh_home : ssh_home
      File.join base_dir, PUBLIC_KEY_NAME
    end


    def private_key
      File.join ssh_home, PRIVATE_KEY_NAME
    end


    def ssh_home
      if lucie_ssh_key_pair_exist?
        lucie_ssh_home
      elsif user_ssh_key_pair_exist?
        user_ssh_home
      else
        raise "No ssh keypair found!"
      end
    end


    #--
    # [FIXME] @ssh_home での切り替えは implicit すぎ
    #++ 
    def authorized_keys
      File.join @ssh_home || user_ssh_home, "authorized_keys"
    end


    ############################################################################
    private
    ############################################################################


    def home
      @debug_options && @debug_options[ :home ] || File.expand_path( "~" )
    end


    def user_ssh_home
      File.join home, ".ssh"
    end


    def user_public_key
      File.join user_ssh_home, PUBLIC_KEY_NAME
    end


    def user_private_key
      File.join user_ssh_home, PRIVATE_KEY_NAME
    end


    def lucie_ssh_home
      File.join home, ".lucie"
    end


    def lucie_public_key
      File.join lucie_ssh_home, PUBLIC_KEY_NAME
    end


    def lucie_private_key
      File.join lucie_ssh_home, PRIVATE_KEY_NAME
    end


    def lucie_ssh_key_pair_exist?
      FileTest.exist?( lucie_public_key ) and FileTest.exist?( lucie_private_key )
    end


    def user_ssh_key_pair_exist?
      FileTest.exist?( user_public_key ) and FileTest.exist?( user_private_key )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
