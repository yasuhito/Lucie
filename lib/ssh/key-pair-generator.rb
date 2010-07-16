require "lucie/utils"


class SSH::KeyPairGenerator
  include Lucie::Utils
  include SSH::Path


  #
  # Creates a SSH key-pair generator. The following options are available:
  #
  # <tt>:logger</tt>:: Save logs with the specified logger [nil]
  # <tt>:verbose</tt>:: Be verbose [nil] 
  # <tt>:dry_run</tt>:: Print the commands that would be executed, but do not execute them. [nil]
  # 
  # Usage:
  #
  #   # New SSH key-pair generator
  #   generator = SSH::KeyPairGenerator.new
  #
  #   # New SSH key-pair generator, with logging
  #   logger = Lucie::Logger::Installer.new
  #   generator = SSH::KeyPairGenerator.new( :logger => logger )
  #
  #   # New SSH key-pair generator, dry-run mode
  #   generator = SSH::KeyPairGenerator.new( :dry_run => true )
  #
  def initialize debug_options = {}
    @debug_options = debug_options
  end


  #
  # Authorizes the public key on localhost. If an SSH key-pair not
  # found, generates a new ssh keypair.
  #
  def start
    begin
      SSH::Home.new( ssh_home, @debug_options ).setup
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


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
