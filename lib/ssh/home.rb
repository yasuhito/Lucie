require "lucie/debug"
require "lucie/utils"
require "ssh/path"


#
# Setups ssh home directory (e.g., ~/.ssh, ~/.lucie, and [nfsroot]/root/.ssh).
#
class SSH::Home
  include Lucie::Debug
  include Lucie::Utils
  include SSH::Path


  def initialize ssh_home, debug_options = {}
    @ssh_home = ssh_home
    @debug_options = debug_options
  end


  def setup
    maybe_mkdir
    maybe_chmod
    maybe_authorize_public_key
    maybe_chmod_authorized_keys
  end


  ############################################################################
  private
  ############################################################################


  def maybe_mkdir
    if dry_run || ( not FileTest.directory?( @ssh_home ) )
      run "mkdir -p #{ @ssh_home }", @debug_options
      # mkdir_p @ssh_home, @debug_options
    end
  end


  def maybe_chmod
    if dry_run || permission_of( @ssh_home ) != "0700"
      run "chmod 0700 #{ @ssh_home }", @debug_options
    end
  end


  def maybe_authorize_public_key
    if dry_run || ( not authorized? )
      run "cat #{ public_key } >> #{ authorized_keys }", @debug_options
    end
  end


  def maybe_chmod_authorized_keys
    if authorized_keys_with_wrong_permission?
      run "chmod 0644 #{ authorized_keys }", @debug_options
    end
  end


  def authorized_keys_with_wrong_permission?
    dry_run || permission_of( authorized_keys ) != "0644"
  end


  def authorized?
    FileTest.exists?( authorized_keys ) && authorized_keys_list.include?( public_key_content )
  end


  def authorized_keys_list
    IO.read( authorized_keys ).split( "\n" )
  end


  def public_key_content
    IO.read( public_key ).chomp
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
