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
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
