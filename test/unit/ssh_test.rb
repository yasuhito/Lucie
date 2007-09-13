require File.dirname( __FILE__ ) + '/../test_helper'


class SSHTest < Test::Unit::TestCase
  include FileSandbox


  def teardown
    Rake::Task.clear
  end


  def test_setup___SUCCESS___
    SSH.stubs( :configure )
    task = Object.new
    task.stubs( :invoke )
    Rake::Task.stubs( :[] ).with( 'installer:ssh' ).returns( task )

    assert_nothing_raised do
      SSH.setup
    end
  end


  def test_should_raise_if_no_ssh_is_available_in_nfsroot
    in_sandbox do | sandbox |
      SSH.configure do | ssh |
        ssh.target_directory = sandbox.root
      end

      assert_raises( "No ssh executable was found in #{ sandbox.root }" ) do
        Rake::Task[ 'installer:ssh' ].invoke
      end
    end
  end


  def test_should_root_sshdir_created_and_is_mode_700
    in_sandbox do | sandbox |
      sandbox.new :file => '/usr/bin/ssh'
      sandbox.new :file => '/etc/ssh/sshd_config'

      SSH.configure do | ssh |
        ssh.target_directory = sandbox.root
      end

      assert_nothing_raised do
        Rake::Task[ 'installer:ssh' ].invoke
      end

      assert FileTest.exists?( File.join( sandbox.root, '/root/.ssh' ) )
      assert_equal 040700, File.stat( File.join( sandbox.root, '/root/.ssh' ) ).mode
    end
  end


  def test_should_root_login_enabled
    in_sandbox do | sandbox |
      sandbox.new :file => '/usr/bin/ssh'
      sandbox.new :file => '/etc/ssh/sshd_config', :with_content => 'PermitRootLogin no'

      SSH.configure do | ssh |
        ssh.target_directory = sandbox.root
      end

      assert_nothing_raised do
        Rake::Task[ 'installer:ssh' ].invoke
      end

      assert_equal 'PermitRootLogin yes', File.read( sandbox.root + '/etc/ssh/sshd_config' )
    end
  end


  def test_should_ssh_known_hosts_file_copied
    in_sandbox do | sandbox |
      sandbox.new :file => '/usr/bin/ssh'
      sandbox.new :file => '/.ssh/id_rsa.pub'
      sandbox.new :file => '/.ssh/known_hosts'
      sandbox.new :file => '/etc/ssh/sshd_config'

      SSH.configure do | ssh |
        ssh.target_directory = sandbox.root
        ssh.ssh_user_home = sandbox.root
      end

      assert_nothing_raised do
        Rake::Task[ 'installer:ssh' ].invoke
      end

      assert FileTest.exists?( sandbox.root + '/root/.ssh/known_hosts' )
    end
  end


  def test_exception_raised_if_no_ssh_pulic_key_found
    in_sandbox do | sandbox |
      sandbox.new :file => '/usr/bin/ssh'
      sandbox.new :file => '/etc/ssh/sshd_config'

      SSH.configure do | ssh |
        ssh.target_directory = sandbox.root
        ssh.ssh_user_home = sandbox.root
      end

      assert_raises( "No ssh public key was found in #{ File.join( sandbox.root, '/.ssh/' ) }" ) do
        Rake::Task[ 'installer:ssh' ].invoke
      end
    end
  end


  def test_should_id_dsa_file_copied
    in_sandbox do | sandbox |
      sandbox.new :file => '/usr/bin/ssh'
      sandbox.new :file => '/.ssh/id_dsa.pub'
      sandbox.new :file => '/etc/ssh/sshd_config'

      SSH.configure do | ssh |
        ssh.target_directory = sandbox.root
        ssh.ssh_user_home = sandbox.root
      end

      assert_nothing_raised do
        Rake::Task[ 'installer:ssh' ].invoke
      end

      assert FileTest.exists?( sandbox.root + '/root/.ssh/authorized_keys' )
      assert_equal 0100644, File.stat( sandbox.root + '/root/.ssh/authorized_keys' ).mode
    end
  end


  def test_should_id_rsa_file_copied
    in_sandbox do | sandbox |
      sandbox.new :file => '/usr/bin/ssh'
      sandbox.new :file => '/.ssh/id_rsa.pub'
      sandbox.new :file => '/etc/ssh/sshd_config'

      SSH.configure do | ssh |
        ssh.target_directory = sandbox.root
        ssh.ssh_user_home = sandbox.root
      end

      assert_nothing_raised do
        Rake::Task[ 'installer:ssh' ].invoke
      end

      assert FileTest.exists?( sandbox.root + '/root/.ssh/authorized_keys' )
      assert_equal 0100644, File.stat( sandbox.root + '/root/.ssh/authorized_keys' ).mode
    end
  end
end
