require "lucie/utils"
require "ssh/home"
require "ssh/path"


class SSH::Nfsroot
  include Lucie::Utils
  include SSH::Path


  #
  # Creates a new nfsroot configurator which sets up password-less SSH
  # access to nfsroot. The following options are available:
  #
  # <tt>:logger</tt>:: Save logs with the specified logger [nil]
  # <tt>:verbose</tt>:: Be verbose [nil] 
  # <tt>:dry_run</tt>:: Print the commands that would be executed, but do not execute them. [nil]
  #
  # Usage:
  #
  #   # New nfsroot configurator
  #   configurator = SSH::Nfsroot.new( "/tmp/nfsroot" )
  #
  #   # New nfsroot configurator, with logging
  #   configurator = SSH::Nfsroot.new( "/tmp/nfsroot", :logger => logger )
  #
  #   # New nfsroot configurator, verbose mode
  #   configurator = SSH::Nfsroot.new( "/tmp/nfsroot", :verbose => true )
  #
  #   # New nfsroot configurator, dry-run mode
  #   configurator = SSH::Nfsroot.new( "/tmp/nfsroot", :dry_run => true )
  #
  def initialize base_dir, debug_options
    @base_dir = base_dir
    @ssh_home = SSH::Home.new( nfsroot_ssh_home, debug_options )
    @debug_options = debug_options
  end


  #
  # Sets up sshd and ssh homedir on nfsroot.
  #
  def setup_ssh_access
    setup_sshd
    setup_ssh_home
    info "ssh access to nfsroot configured."
  end


  ############################################################################
  private
  ############################################################################


  require "rbconfig"
  def ruby
    File.join( RbConfig::CONFIG[ "bindir" ], RbConfig::CONFIG[ "ruby_install_name" ] )
  end


  def setup_sshd
    sshd_config = path( "/etc/ssh/sshd_config" )
    run <<-COMMANDS, @debug_options
#{ ruby } -pi -e 'gsub( /PermitRootLogin no/, "PermitRootLogin yes" )' #{ sshd_config }
#{ ruby } -pi -e 'gsub( /.*PasswordAuthentication.*/, "PasswordAuthentication no" )' #{ sshd_config }
echo "UseDNS no" >> #{ sshd_config }
COMMANDS
  end


  def setup_ssh_home
    @ssh_home.setup
  end


  def nfsroot_ssh_home
    path "root/.ssh"
  end


  def path the_path
    File.join( @base_dir, the_path ).gsub( /\/+/, "/" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
