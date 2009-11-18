require "lucie/utils"


module SSHHome
  def setup_ssh_home target
    Lucie::Utils.mkdir_p target, @debug_options unless FileTest.directory?( target )
    Lucie::Utils.run "chmod 0700 #{ target }", @debug_options
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
