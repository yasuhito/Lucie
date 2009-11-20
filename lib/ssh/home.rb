require "lucie/debug"
require "lucie/utils"


class SSH
  module Home
    include Lucie::Debug


    def setup_ssh_home target
      Lucie::Utils.mkdir_p target, @debug_options unless FileTest.directory?( target )
      if dry_run || File.stat( target ).mode.to_s( 8 ) != "40700"
        Lucie::Utils.run "chmod 0700 #{ target }", @debug_options
      end
    end


    def ssh_home
      if FileTest.exists?( lucie_public_key_path ) and FileTest.exists?( lucie_private_key_path )
        lucie_ssh_home
      else
        user_ssh_home
      end
    end


    def public_key_path
      File.join ssh_home, "id_rsa.pub"
    end


    def private_key_path
      File.join ssh_home, "id_rsa"
    end


    def authorized_keys_path
      File.join ssh_home, "authorized_keys"
    end


    def lucie_public_key_path
      File.join lucie_ssh_home, "id_rsa.pub"
    end


    def lucie_private_key_path
      File.join lucie_ssh_home, "id_rsa"
    end


    def user_ssh_home
      File.join home, ".ssh"
    end


    def home
      ( @debug_options && @debug_options[ :home ] ) ? @debug_options[ :home ] : File.expand_path( "~" )
    end


    def lucie_ssh_home
      File.join lucie_home, ".ssh"
    end


    def lucie_home
      ( @debug_options && @debug_options[ :lucie_home ] ) ? @debug_options[ :lucie_home ] : Lucie::ROOT
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
