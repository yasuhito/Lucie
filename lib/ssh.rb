# -*- coding: utf-8 -*-
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


  attr_accessor :user
  attr_accessor :target_directory

  attr_accessor :dry_run # :nodoc:
  attr_accessor :messenger # :nodoc:
  attr_accessor :verbose # :nodoc:


  def self.setup &block
    self.configure( &block )
    Rake::Task[ "installer:ssh" ].invoke
  end


  def self.configure &block # :nodoc:
    ssh = self.new
    block.call ssh
    ssh.check_prerequisites
    ssh.define_tasks
    ssh.define_task_dependencies
  end


  def initialize options = {}, messenger = nil
    @verbose = options[ :verbose ]
    @dry_run = options[ :dry_run ]
    @messenger = messenger
  end


  def define_tasks  # :nodoc:
    define_task_installer_ssh
    define_task_ssh_directory
    define_task_target_root_ssh_home
    define_task_local_authorized_keys
    define_task_target_authorized_keys
    define_task_private_key_file
  end


  def define_task_dependencies  # :nodoc:
    task "installer:ssh" => [ target_authorized_keys, local_authorized_keys ]
    task local_authorized_keys => PUBLIC_KEY
    task target_authorized_keys => [ target_root_ssh_home, PUBLIC_KEY, PRIVATE_KEY ]
    task PRIVATE_KEY => LOCAL_SSH_HOME
    task PUBLIC_KEY => LOCAL_SSH_HOME
  end


  def check_prerequisites  # :nodoc:
    return if @dry_run
    unless FileTest.exists?( target( "/usr/bin/ssh" ) )
      raise "No ssh executable was found in #{ @target_directory }"
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def run commands
    commands.split( "\n" ).each do | each |
      next if /^#/=~ each
      next if /^\s*$/=~ each
      Lucie::Utils.run each, { :verbose => @verbose, :dry_run => @dry_run }, @messenger      
    end
  end


  # tasks ######################################################################


  def define_task_installer_ssh
    task "installer:ssh" do
      run <<-COMMANDS
ruby -pi -e 'gsub( /PermitRootLogin no/, "PermitRootLogin yes" )' #{ target( "/etc/ssh/sshd_config" ) }
ruby -pi -e 'gsub( /.*PasswordAuthentication.*/, "PasswordAuthentication no" )' #{ target( "/etc/ssh/sshd_config" ) }
echo "UseDNS no" >> #{ target( "/etc/ssh/sshd_config" ) }
COMMANDS
      info "ssh access to nfsroot configured."
    end
  end


  def define_task_ssh_directory
    directory LOCAL_SSH_HOME do
      run "chown #{ @user }:#{ @user } #{ LOCAL_SSH_HOME }"
      run "chmod 0700 #{ LOCAL_SSH_HOME }"
    end
  end


  def define_task_target_root_ssh_home
    directory target_root_ssh_home do
      run "chmod 0700 #{ target_root_ssh_home }"
    end
  end


  # [TODO] バックアップを取るべし。
  def define_task_local_authorized_keys
    file local_authorized_keys do
      unless FileTest.exists?( local_authorized_keys )
        run "cp #{ PUBLIC_KEY } #{ local_authorized_keys }"
      else
        authorized_keys = IO.read( local_authorized_keys ).split( "\n" )
        public_key = IO.read( PUBLIC_KEY ).chomp
        unless authorized_keys.include?( public_key )
          run "cat #{ PUBLIC_KEY } >> #{ local_authorized_keys }"
        end
      end
      run "chmod 0644 #{ local_authorized_keys }"
      run "chown #{ @user }:#{ @user } #{ local_authorized_keys }"
    end
  end


  def define_task_target_authorized_keys
    file target_authorized_keys do
      run "cp #{ PUBLIC_KEY } #{ target_authorized_keys }"
      run "chmod 0644 #{ target_authorized_keys }"
    end
  end


  def define_task_private_key_file
    file PRIVATE_KEY do
      run <<-COMMANDS
ssh-keygen -t rsa -N "" -f #{ PRIVATE_KEY }
chown #{ @user }:#{ @user } #{ PUBLIC_KEY }
chown #{ @user }:#{ @user } #{ PRIVATE_KEY }
COMMANDS
    end
  end


  # targets ####################################################################


  def local_authorized_keys
    File.expand_path "~/.ssh/authorized_keys"
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
