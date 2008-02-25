require 'fileutils'
require 'popen3/shell'
require 'rake/tasklib'


class SSH < Rake::TaskLib
  attr_accessor :ssh_user_home
  attr_accessor :target_directory


  def initialize
    @ssh_user_home = File.expand_path( '~/' )
  end


  def self.configure &block
    ssh = self.new
    block.call ssh
    ssh.define_tasks
    return ssh
  end


  def self.setup &block
    self.configure &block
    Rake::Task[ 'installer:ssh' ].invoke
  end


  def define_tasks
    namespace 'installer' do
      task 'ssh' do
        unless FileTest.exists?( target( '/usr/bin/ssh' ) )
          raise "No ssh executable was found in #{ @target_directory }"
        end

        FileUtils.mkdir_p target( '/root/.ssh' )
        FileUtils.chmod 0700, target( '/root/.ssh' )

        if FileTest.exists?( ssh_user_home + '/.ssh/known_hosts' )
          FileUtils.cp ssh_user_home + '/.ssh/known_hosts', target( '/root/.ssh/known_hosts' )
        end
        register_authorized_keys

        sh_exec %{ruby -pi -e 'gsub( /PermitRootLogin no/, "PermitRootLogin yes" )' #{ target( '/etc/ssh/sshd_config' ) }}
      end
    end
  end


  private


  def register_authorized_keys
    [ 'dsa', 'rsa' ].each do | each |
      if FileTest.exists?( public_key_file( each ) )
        File.open( authorized_keys_file, 'a+' ) do | authorized_keys |
          authorized_keys.puts public_key_contents( each )
        end
        FileUtils.chmod 0644, authorized_keys_file
        return
      end
    end
    raise "No ssh public key was found in #{ File.join( ssh_user_home, '/.ssh/' ) }"
  end


  def public_key_contents type
    contents = nil
    File.open( public_key_file( type ), 'r' ) do | file |
      contents = file.read
    end
    contents
  end


  def public_key_file type
    File.join( ssh_user_home, '/.ssh/', "id_#{ type }.pub" )
  end


  def authorized_keys_file
    return target( '/root/.ssh/authorized_keys' )
  end


  def target path
    return File.join( @target_directory, path ).gsub( /\/+/, '/' )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
