require File.dirname( __FILE__ ) + '/../spec_helper'


# As a Lucie commandline script,
# I want to start daemonized druby server (Lucie daemon),
# so that I can delegate jobs to Lucie daemon at any time.

describe LucieDaemon, 'when starting Lucie daemon' do
  it 'should return a DRbObject with LucieDaemon.server' do
    # expects
    DRbObject.expects( :new_with_uri ).with( "druby://127.0.0.1:58243" ).returns( 'LUCIE_SERVER' )

    # when, then
    LucieDaemon.server.should == 'LUCIE_SERVER'
  end


  it 'should log errors when failed to start lucied' do
    Daemon::Controller.stubs( :fork ).yields.returns( false )
    Process.stubs( :setsid ).raises

    # expects
    Lucie::Log.expects( :error )
    Daemon::Controller.expects( :exit ).with( 1 )

    # when, then
    LucieDaemon.daemonize
  end


  it 'should be daemonized and druby enabled' do
    @lucie_daemon = LucieDaemon.new
    @drb_threads = Object.new
    LucieDaemon.stubs( :new ).returns( @lucie_daemon )
    Lucie::Log.stubs( :info )

    # expects
    Daemon::Controller.expects( :fork ).yields.times( 2 ).returns( false )
    Process.expects( :setsid )
    LuciedBlocker.expects( :block )
    LuciedBlocker::PidFile.expects( :store )
    Dir.expects( :chdir )
    File.expects( :umask ).with( 0000 )
    STDIN.expects( :reopen )
    STDOUT.expects( :reopen )
    STDERR.expects( :reopen )

    # SIGTERM handler
    Daemon::Controller.expects( :trap ).with( 'TERM' ).yields
    DRb.expects( :stop_service )
    Daemon::Controller.stubs( :exit )

    DRb.expects( :start_service ).with( 'druby://127.0.0.1:58243', @lucie_daemon )
    @drb_threads.expects( :join )
    DRb.expects( :thread ).returns( @drb_threads )

    # when, then
    lambda do
      LucieDaemon.daemonize
    end.should_not raise_error
  end
end


# As a Lucie commandline script,
# I want to stop Lucie daemon with LucieDaemon.kill
# so that I dont have to know about Lucie daemon in detail.

describe LucieDaemon, 'when calling LucieDaemon.kill' do
  it 'should exit if pid file not found' do
    STDERR.stubs( :puts )
    File.stubs( :file? ).returns( false )

    # when
    lambda do
      LucieDaemon.kill
      # then
    end.should raise_error( SystemExit )
    verify_mocks
  end


  it 'should send TERM signal' do
    File.stubs( :file? ).returns( true )

    # expects
    LuciedBlocker::PidFile.expects( :recall ).returns( 'DUMMY_PID' )
    LuciedBlocker.expects( :release )
    Process.expects( :kill ).with( 'TERM', 'DUMMY_PID' )

    # when
    LucieDaemon.kill

    # then
    verify_mocks
  end
end


# As a Lucie commandline script,
# I want to delegate jobs to root privileged Lucie daemon with helper methods ,
# so that I can be executed without root privilege.

describe LucieDaemon, 'when calling helper methods' do
  before( :each ) do
    @lucie_daemon = LucieDaemon.new
  end


  it "should sudo('pwd') without errors" do
    log = Object.new
    File.stubs( :open ).with( 'LOG_FILE', 'w' ).returns( log )

    # expects
    Lucie::Log.expects( :info ).at_least_once
    log.expects( :sync= ).with( true )
    log.expects( :puts ).at_least_once
    log.expects( :close )

    # when
    lambda do
      @lucie_daemon.sudo( 'pwd', 'LOG_FILE' )

      # then
    end.should_not raise_error
  end


  it "should raise if sudo('invalid command')" do
    Lucie::Log.stubs( :info )
    File.stubs( :open ).with( 'LOGFILE', 'w' ).returns( StringIO.new( '' ) )

    # when
    lambda do
      @lucie_daemon.sudo( 'INVALID_COMMAND', 'LOGFILE' )
    end.should raise_error( RuntimeError )

    # then
    verify_mocks
  end


  it 'should log sudo output' do
    shell = Object.new
    Popen3::Shell.stubs( :open ).yields( shell )

    shell.stubs( :on_stdout ).yields( 'STDOUT' )
    shell.stubs( :on_stderr ).yields( 'STDOUT' )
    shell.stubs( :on_failure )
    shell.stubs( :exec )

    log = Object.new
    File.stubs( :open ).with( 'LOG_FILE', 'w' ).returns( log )

    # expects
    Lucie::Log.expects( :info ).at_least_once
    log.expects( :sync= ).with( true )
    log.expects( :puts ).at_least_once
    log.expects( :close ).at_least_once

    # when
    lambda do
      @lucie_daemon.sudo( 'COMMAND', 'LOG_FILE' )

      # then
    end.should_not raise_error
  end


  it 'should enable a node' do
    node = Object.new

    # expects
    Nodes.expects( :find ).with( 'NODE_NAME' ).returns( node )
    node.expects( :enable! ).with( 'INSTALLER_NAME' )

    # when
    lambda do
      @lucie_daemon.enable_node( 'NODE_NAME', 'INSTALLER_NAME' )

      # then
    end.should_not raise_error
  end


  it 'should setup TFTP' do
    # expects
    Tftp.expects( :setup ).with( 'NODE_NAME', 'INSTALLER_NAME' )

    # when
    lambda do
      @lucie_daemon.setup_tftp( 'NODE_NAME', 'INSTALLER_NAME' )

      # then
    end.should_not raise_error
  end


  it 'should setup NFS' do
    # expects
    Nfs.expects( :setup ).with( 'INSTALLER_NAME' )

    # when
    lambda do
      @lucie_daemon.setup_nfs( 'INSTALLER_NAME' )

      # then
    end.should_not raise_error
  end


  it 'should setup DHCP' do
    node = Object.new

    # expects
    Nodes.expects( :find ).with( 'NODE_NAME' ).returns( node )
    node.expects( :installer_name ).returns( 'INSTALLER_NAME' )
    node.expects( :ip_address ).returns( 'IP_ADDRESS' )
    node.expects( :netmask_address ).returns( 'NETMASK_ADDRESS' )
    node.expects( :gateway_address ).returns( 'GATEWAY_ADDRESS' )
    Dhcp.expects( :setup ).with( 'INSTALLER_NAME', 'IP_ADDRESS', 'NETMASK_ADDRESS', 'GATEWAY_ADDRESS' )

    # when
    lambda do
      @lucie_daemon.setup_dhcp( 'NODE_NAME' )

      # then
    end.should_not raise_error
  end


  it 'should setup Puppet' do
    installer = Object.new

    # expects
    Installers.expects( :find ).with( 'INSTALLER_NAME' ).returns( installer )
    installer.expects( :local_checkout ).returns( installer )
    PuppetController.expects( :setup ).with( installer )

    # when
    lambda do
      @lucie_daemon.setup_puppet( 'INSTALLER_NAME' )

      # then
    end.should_not raise_error
  end


  it 'should send Wake on Lan magick packets' do
    node = Object.new

    # expects
    Nodes.expects( :find ).with( 'NODE_NAME' ).returns( node )
    node.expects( :mac_address ).returns( 'MAC_ADDRESS' )
    WakeOnLan.expects( :wake ).with( 'MAC_ADDRESS' )

    # when
    lambda do
      @lucie_daemon.wol( 'NODE_NAME' )

      # then
    end.should_not raise_error
  end


  it 'should disable a node' do
    node = Object.new

    # expects
    Nodes.expects( :find ).with( 'NODE_NAME' ).returns( node )
    node.expects( :disable! )
    Tftp.expects( :disable ).with( 'NODE_NAME' )

    # when
    @lucie_daemon.disable_node( 'NODE_NAME' )

    # then
    verify_mocks
  end


  it "should raise if disable_node('UNKNOWN_NODE')" do
    # expects
    Nodes.expects( :find ).with( 'UNKNOWN_NODE' )

    # when
    lambda do
      @lucie_daemon.disable_node( 'UNKNOWN_NODE' )

      # then
    end.should raise_error( RuntimeError, 'Node UNKNOWN_NODE not found!' )
  end


  it 'should restart Puppet daemon' do
    # expects
    PuppetController.expects( :restart )

    # when
    lambda do
      @lucie_daemon.restart_puppet

      # then
    end.should_not raise_error
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
