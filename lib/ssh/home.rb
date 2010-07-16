require "lucie/debug"
require "lucie/utils"
require "ssh/path"


class SSH::Home
  include Lucie::Utils
  include SSH::Path


  #
  # Creates an SSH home-directory configurator. The following options are available:
  #
  # <tt>:logger</tt>:: Save logs with the specified logger [nil]
  # <tt>:verbose</tt>:: Be verbose [nil] 
  # <tt>:dry_run</tt>:: Print the commands that would be executed, but do not execute them. [nil]
  #
  # Usage:
  #
  #   # New SSH home-directory configurator
  #   home = SSH::Home.new( "~/.ssh" )
  #
  #   # New SSH home-directory configurator, with logging
  #   logger = Lucie::Logger::Installer.new
  #   home = SSH::Home.new( "~/.ssh", :logger => logger )
  #
  #   # New SSH key-pair generator, dry-run mode
  #   home = SSH::Home.new( "~/.ssh", :dry_run => true )
  #
  def initialize ssh_home, debug_options = {}
    @ssh_home = ssh_home
    @debug_options = debug_options
  end


  #
  # Sets up SSH home directory. 
  #
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
      mkdir_p @ssh_home, @debug_options
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
