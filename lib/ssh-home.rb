require "lucie/utils"


module SSHHome
  include Lucie::Debug
  include Lucie::Utils


  def setup_ssh_home target
    mkdir_p target, @debug_options unless FileTest.directory?( target )
    if dry_run || File.stat( target ).mode.to_s( 8 ) != "40700"
      run "chmod 0700 #{ target }", @debug_options
    end
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


  def ssh_home
    File.join @debug_options[ :home ] || File.expand_path( "~" ), ".ssh"
  end


  def lucie_ssh_home
    File.join @debug_options[ :lucie_home ] || Lucie::ROOT, ".ssh"
  end


  def local_ssh_home
    if FileTest.exists?( lucie_public_key_path ) and FileTest.exists?( lucie_private_key_path )
      lucie_ssh_home
    else
      ssh_home
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
