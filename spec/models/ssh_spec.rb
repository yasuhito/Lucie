require File.dirname( __FILE__ ) + '/../spec_helper'


describe SSH do
  before( :each ) do
    Rake::Task.clear
  end


  it 'should setup successfully' do
    SSH.stubs( :configure )
    task = Object.new
    task.stubs( :invoke )
    Rake::Task.stubs( :[] ).with( 'installer:ssh' ).returns( task )

    lambda do
      SSH.setup
    end.should_not raise_error
  end


  it 'should raise if no ssh is available in the nfsroot' do
    in_sandbox do | sandbox |
      SSH.configure do | ssh |
        ssh.target_directory = sandbox.root
      end

      lambda do
        Rake::Task[ 'installer:ssh' ].invoke
      end.should raise_error( RuntimeError, "No ssh executable was found in #{ sandbox.root }" )
    end
  end


  it 'should copy known_host file' do
    in_sandbox do | sandbox |
      sandbox.new :file => '/usr/bin/ssh'
      sandbox.new :file => '/etc/ssh/sshd_config'
      sandbox.new :file => '/.ssh/id_rsa.pub'

      SSH.configure do | ssh |
        ssh.stubs( :register_authorized_keys )
        ssh.stubs( :sh_exec )
        ssh.stubs( :ssh_user_home ).returns( sandbox.root )
        ssh.target_directory = sandbox.root
      end

      lambda do
        Rake::Task[ 'installer:ssh' ].invoke
      end.should_not raise_error

      FileTest.exists?( File.join( sandbox.root, '/root/.ssh' ) ).should == true
    end
  end


  it 'should create root ssh directory' do
    in_sandbox do | sandbox |
      sandbox.new :file => '/usr/bin/ssh'
      sandbox.new :file => '/etc/ssh/sshd_config'
      sandbox.new :file => '/.ssh/id_rsa.pub'
      sandbox.new :file => '/.ssh/known_hosts'

      SSH.configure do | ssh |
        ssh.stubs( :register_authorized_keys )
        ssh.stubs( :sh_exec )
        ssh.stubs( :ssh_user_home ).returns( sandbox.root )
        ssh.target_directory = sandbox.root
      end

      lambda do
        Rake::Task[ 'installer:ssh' ].invoke
      end.should_not raise_error

      FileTest.exists?( File.join( sandbox.root, '/root/.ssh/known_hosts' ) ).should == true
    end
  end


  it 'should enable root ssh login' do
    in_sandbox do | sandbox |
      sandbox.new :file => '/usr/bin/ssh'
      sandbox.new :file => '/etc/ssh/sshd_config', :with_content => 'PermitRootLogin no'
      sandbox.new :file => '.ssh/id_rsa.pub'

      FileUtils.stubs( :chmod )

      SSH.configure do | ssh |
        ssh.expects( :sh_exec ).with( %{ruby -pi -e 'gsub( /PermitRootLogin no/, "PermitRootLogin yes" )' #{ File.join( sandbox.root, '/etc/ssh/sshd_config' ) }} )
        ssh.stubs( :register_authorized_keys )
        ssh.stubs( :ssh_user_home ).returns( sandbox.root )
        ssh.target_directory = sandbox.root
      end

      lambda do
        Rake::Task[ 'installer:ssh' ].invoke
      end.should_not raise_error
    end
  end


  it 'should raise if no ssh public key was found' do
    in_sandbox do | sandbox |
      sandbox.new :file => '/usr/bin/ssh'
      sandbox.new :file => '/etc/ssh/sshd_config'

      SSH.configure do | ssh |
        ssh.target_directory = sandbox.root
        ssh.ssh_user_home = sandbox.root
      end

      lambda do
        Rake::Task[ 'installer:ssh' ].invoke
      end.should raise_error( RuntimeError, "No ssh public key was found in #{ File.join( sandbox.root, '/.ssh/' ) }" )
    end
  end


  it 'should copy id_dsa file' do
    in_sandbox do | sandbox |
      sandbox.new :file => '/usr/bin/ssh'
      sandbox.new :file => '/.ssh/id_dsa.pub'
      sandbox.new :file => '/etc/ssh/sshd_config'

      FileUtils.stubs( :chmod )

      SSH.configure do | ssh |
        ssh.stubs( :sh_exec )
        ssh.target_directory = sandbox.root
        ssh.ssh_user_home = sandbox.root
      end

      assert_nothing_raised do
        Rake::Task[ 'installer:ssh' ].invoke
      end

      FileTest.exists?( authorized_keys_file( sandbox.root ) ).should == true
    end
  end


  it 'should copy id_rsa file' do
    in_sandbox do | sandbox |
      sandbox.new :file => '/usr/bin/ssh'
      sandbox.new :file => '/.ssh/id_rsa.pub'
      sandbox.new :file => '/etc/ssh/sshd_config'

      FileUtils.stubs( :chmod )

      SSH.configure do | ssh |
        ssh.stubs( :sh_exec )
        ssh.target_directory = sandbox.root
        ssh.ssh_user_home = sandbox.root
      end

      assert_nothing_raised do
        Rake::Task[ 'installer:ssh' ].invoke
      end

      FileTest.exists?( authorized_keys_file( sandbox.root ) ).should == true
    end
  end


  def authorized_keys_file root
    File.join( root, '/root/.ssh/authorized_keys' )
  end
end
