require File.dirname( __FILE__ ) + '/../spec_helper'


describe Install do
  it 'should have default label 0' do
    with_sandbox_node do | sandbox, node |
      install = Install.new( node, nil )

      install.label.should == 0
    end
  end


  it 'should load status file and build log' do
    with_sandbox_node do | sandbox, node |
      sandbox.new :file => 'install-2/install_status.success.in9.235s'
      sandbox.new :file => 'install-2/install.log', :with_content => 'SOME CONTENT'
      install = Install.new( node, 2 )

      install.label.should == 2
      install.should be_successful
      install.output.should == 'SOME CONTENT'
    end
  end


  it 'should load latest label' do
    with_sandbox_node do | sandbox, node |
      sandbox.new :file => 'install-1/install_status.success.in9.235s'
      sandbox.new :file => 'install-1/install.log', :with_content => 'SOME CONTENT'
      sandbox.new :file => 'install-2/install_status.success.in9.235s'
      sandbox.new :file => 'install-2/install.log', :with_content => 'SOME CONTENT'
      install = Install.new( node, :latest )

      install.label.should == 2
    end
  end


  it 'should create new install' do
    with_sandbox_node do | sandbox, node |
      install = Install.new( node, :new )

      install.label.should == 0
    end
  end


  it 'should create new label' do
    with_sandbox_node do | sandbox, node |
      sandbox.new :file => 'install-1/install_status.success.in9.235s'
      sandbox.new :file => 'install-1/install.log', :with_content => 'SOME CONTENT'

      install = Install.new( node, :new )

      install.label.should == 2
    end
  end


  it 'should load failed status file' do
    with_sandbox_node do | sandbox, node |
      sandbox.new :file => 'install-2/install_status.failed.in2s'
      install = Install.new( node, 2 )

      install.should be_failed
    end
  end


  it 'should grab log file when file exists' do
    with_sandbox_node do | sandbox, node |
      sandbox.new :file => "install-1/install.log", :with_contents => 'INSTALL_LOG'

      Install.new( node, 1 ).output.should == 'INSTALL_LOG'
    end
  end


  it 'should give empty output when log file does not exist' do
    with_sandbox_node do | sandbox, node |
      File.stubs( :read ).with( "#{ node.path }/install-1/install.log" ).raises( StandardError )

      Install.new( node, 1 ).output.should == ''
    end
  end


  it 'should detect installation result' do
    with_sandbox_node do | sandbox, node |
      sandbox.new :file => 'install-1/install_status.success'
      sandbox.new :file => 'install-2/install_status.Success'
      sandbox.new :file => 'install-3/install_status.failure'
      sandbox.new :file => 'install-4/install_status.crap'
      sandbox.new :file => 'install-5/foo'

      Install.new( node, 1 ).should be_successful
      Install.new( node, 2 ).should be_successful
      Install.new( node, 3 ).should_not be_successful
      Install.new( node, 4 ).should_not be_successful
      Install.new( node, 5 ).should_not be_successful
    end
  end


  it 'should detect incomplete status' do
    with_sandbox_node do | sandbox, node |
      sandbox.new :file => 'install-1/install_status.incomplete'
      sandbox.new :file => 'install-2/install_status.something_else'

      Install.new( node, 1 ).should be_incomplete
      Install.new( node, 2 ).should_not be_incomplete
    end
  end


  it 'should run successful install' do
    INSTALLER_OPTIONS = {}

    with_sandbox_node do | sandbox, node |
      install = Install.new( node, 123 )
      install.stubs( :nfsroot_setting ).returns( nfsroot_setting )

      File.stubs( :open ).returns( install_log )

      InstallStatus.any_instance.stubs( :start! )
      Lucie::Log.stubs( :event )
      Lucie::Log.stubs( :info )
      Lucie::Log.stubs( :fatal )

      install.stubs( :ssh_exec )
      shell = Object.new
      shell.stubs( :on_stdout )
      shell.stubs( :on_stderr )
      shell.stubs( :on_failure )
      shell.stubs( :exec )
      Popen3::Shell.stubs( :open ).yields( shell )

      install.stubs( :sh_exec )
      InstallStatus.any_instance.stubs( :succeed! )
      Facter.stubs( :value )

      lucie_daemon = Object.new
      LucieDaemon.stubs( :server ).returns( lucie_daemon )
      lucie_daemon.stubs( :disable_node )

      lambda do
        install.run
      end.should_not raise_error
    end
  end


  it 'should install fail' do
    with_sandbox_node do | sandbox, node |
      install = Install.new( node, 123 )

      File.stubs( :open ).returns( install_log )

      Time.stubs( :now ).returns( Time.at( 1 ) )
      install.expects( :install ).raises

      InstallStatus.any_instance.expects( :start! )
      InstallStatus.any_instance.expects( :fail! ).with( 0 )

      Lucie::Log.stubs( :fatal )

      lambda do
        install.run
      end.should raise_error
    end
  end


  it 'should install fail with config error' do
    with_sandbox_node do | sandbox, node |
      install = Install.new( node, 123 )

      File.stubs( :open ).returns( install_log )

      Time.stubs( :now ).returns( Time.at( 1 ) )
      install.expects( :install ).raises( ConfigError )

      InstallStatus.any_instance.expects( :start! )
      InstallStatus.any_instance.expects( :fail! )

      Lucie::Log.stubs( :fatal )

      lambda do
        install.run
      end.should raise_error
    end
  end


  it 'should give status' do
    with_sandbox_node do | sandbox, node |
      InstallStatus.any_instance.expects( :to_s ).returns( 'STATUS' )

      Install.new( node, 123 ).status.should == 'STATUS'
    end
  end


  it 'should give time' do
    with_sandbox_node do | sandbox, node |
      InstallStatus.any_instance.expects( :timestamp ).returns( 'TIME' )

      Install.new( node, 123 ).time.should == 'TIME'
    end
  end


  it 'should give elapsed time' do
    with_sandbox_node do | sandbox, node |
      InstallStatus.any_instance.expects( :elapsed_time ).returns( 'ELAPSED TIME' )

      Install.new( node, 123 ).elapsed_time.should == 'ELAPSED TIME'
    end
  end


  def install_log
    StringIO.new
  end


  def nfsroot_setting
    setting = Object.new
    setting.stubs( :arch ).returns( 'i386' )
    setting.stubs( :distribution ).returns( 'debian' )
    setting.stubs( :suite ).returns( 'etch' )
    setting
  end


  def with_sandbox_node &block
    in_total_sandbox do | sandbox |
      node = Node.new( 'TEST_NODE', :mac_address => '11:22:33:44:55:66', :gateway_address => '192.168.1.254', :ip_address => '192.168.1.1', :netmask_address => '255.255.255.0' )
      node.path = sandbox.root

      yield sandbox, node
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
