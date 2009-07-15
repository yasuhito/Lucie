require "rubygems"

require "lucie"
require "lucie/io"
require "lucie/utils"
require "popen3/shell"
require "rake/tasklib"


class SSH < Rake::TaskLib
  include Lucie::IO


  LOCAL_SSH_HOME = File.join( Lucie::ROOT, ".ssh" )
  PRIVATE_KEY = File.join( LOCAL_SSH_HOME, "id_rsa" )
  PUBLIC_KEY = File.join( LOCAL_SSH_HOME, "id_rsa.pub" )
  OPTIONS = %{-o "PasswordAuthentication no" -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" -o "LogLevel=ERROR"}


  attr_accessor :target_directory

  attr_accessor :dry_run # :nodoc:
  attr_accessor :messenger # :nodoc:
  attr_accessor :verbose # :nodoc:


  def self.generate_keypair options = {}, messenger = nil
    ssh = self.new( options, messenger )
    ssh.generate_ssh_keypair
  end


  def self.setup_nfsroot &block
    ssh = self.new
    block.call ssh
    ssh.check_prerequisites
    ssh.define_nfsroot_tasks
    Rake::Task[ "installer:ssh_nfsroot" ].invoke
  end


  def initialize options = {}, messenger = nil
    @ssh_home = options[ :ssh_home ]
    @verbose = options[ :verbose ]
    @dry_run = options[ :dry_run ]
    @messenger = messenger
  end


  def generate_ssh_keypair
    setup_local_ssh_home
    ssh_keygen
    update_local_authorized_keys
  end


  def define_nfsroot_tasks # :nodoc:
    define_task_ssh_nfsroot
    define_task_target_root_ssh_home
    define_task_target_authorized_keys
    task "installer:ssh_nfsroot" => target_authorized_keys
  end


  def check_prerequisites # :nodoc:
    return if @dry_run
    unless FileTest.exists?( target( "/usr/bin/ssh" ) )
      raise "No ssh executable was found in #{ @target_directory }"
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def run command
    Lucie::Utils.run command, { :verbose => @verbose, :dry_run => @dry_run }, @messenger      
  end


  # tasks ######################################################################


  def define_task_ssh_nfsroot
    task "installer:ssh_nfsroot" do
      run <<-COMMANDS
ruby -pi -e 'gsub( /PermitRootLogin no/, "PermitRootLogin yes" )' #{ target( "/etc/ssh/sshd_config" ) }
ruby -pi -e 'gsub( /.*PasswordAuthentication.*/, "PasswordAuthentication no" )' #{ target( "/etc/ssh/sshd_config" ) }
echo "UseDNS no" >> #{ target( "/etc/ssh/sshd_config" ) }
COMMANDS
      info "ssh access to nfsroot configured."
    end
  end


  def define_task_target_root_ssh_home
    directory target_root_ssh_home
    file target_root_ssh_home do
      run "chmod 0700 #{ target_root_ssh_home }"
    end
  end


  def define_task_target_authorized_keys
    file target_authorized_keys => target_root_ssh_home do
      run "cp #{ public_key } #{ target_authorized_keys }"
      run "chmod 0644 #{ target_authorized_keys }"
    end
  end


  def setup_local_ssh_home
    unless FileTest.directory?( LOCAL_SSH_HOME )
      Lucie::Utils.mkdir_p LOCAL_SSH_HOME, { :verbose => @verbose, :dry_run => @dry_run }, @messenger
    end
    run "chmod 0700 #{ LOCAL_SSH_HOME }"
  end


  def ssh_keygen
    unless FileTest.exists?( private_key ) and FileTest.exists?( private_key )
      run %{ssh-keygen -t rsa -N "" -f #{ private_key }}
    end
  end


  def update_local_authorized_keys
    unless FileTest.exists?( local_authorized_keys )
      run "cp #{ public_key } #{ local_authorized_keys }"
    else
      authorized_keys = IO.read( local_authorized_keys ).split( "\n" )
      the_public_key = IO.read( public_key ).chomp
      unless authorized_keys.include?( the_public_key )
        run "cat #{ public_key } >> #{ local_authorized_keys }"
      end
    end
    run "chmod 0644 #{ local_authorized_keys }"
  end


  # targets ####################################################################


  def public_key
    @ssh_home ? File.join( @ssh_home, "id_rsa.pub" ) : PUBLIC_KEY
  end


  def private_key
    @ssh_home ? File.join( @ssh_home, "id_rsa" ) : PRIVATE_KEY
  end


  def local_authorized_keys
    File.expand_path File.join( @ssh_home || "~/.ssh/", "authorized_keys" )
  end


  def target_authorized_keys
    File.join target_root_ssh_home, "authorized_keys"
  end


  def target_root_ssh_home
    target "root/.ssh"
  end


  def target path
    File.join( @target_directory, path ).gsub( /\/+/, "/" )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
