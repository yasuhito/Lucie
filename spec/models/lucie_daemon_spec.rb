require File.dirname( __FILE__ ) + '/../spec_helper'


# As a Lucie commandline script,
# I want to start daemonized druby server (Lucie daemon),
# so that I can delegate jobs to Lucie daemon at any time.

describe LucieDaemon, 'when starting Lucie daemon' do
  before( :each ) do
    ENV[ 'DEBUG' ] = '1'
  end


  after( :each ) do
    ENV[ 'DEBUG' ] = nil
  end


  it 'should be daemonized and druby enabled' do
    @lucie_daemon = LucieDaemon.new
    @drb_threads = Object.new
    LucieDaemon.stubs( :new ).returns( @lucie_daemon )

    # expects
    Daemon::Controller.expects( :fork ).yields.times( 2 ).returns( false )
    Process.expects( :setsid )
    LuciedBlocker::PidFile.expects( :store )
    Dir.expects( :chdir )
    File.expects( :umask )
    STDIN.expects( :reopen )
    STDOUT.expects( :reopen )
    STDERR.expects( :reopen )

    # SIGTERM handler
    Daemon::Controller.expects( :trap ).with( 'TERM' ).yields
    DRb.expects( :stop_service )
    Daemon::Controller.stubs( :exit )

    DRb.expects( :start_service ).with( 'druby://localhost:58243', @lucie_daemon )
    @drb_threads.expects( :join )
    DRb.expects( :thread ).returns( @drb_threads )

    # when
    LucieDaemon.daemonize

    # then
    verify_mocks
  end
end


# As a Lucie commandline script,
# I want to stop Lucie daemon with LucieDaemon.kill
# so that I dont have to know about Lucie daemon in detail.

describe LucieDaemon, 'when calling LucieDaemon.kill' do
  it 'should exit if pid file not found' do
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



# Stubbing LucieDaemon.daemonize

describe 'Lucie Daemon (daemon disabled)', :shared => true do
  before( :each ) do
    @drb_threads = Object.new

    Daemon::Controller.stubs( :fork ).yields.returns( false )
    Process.stubs( :setsid )
    LuciedBlocker.stubs( :block )
    LuciedBlocker::PidFile.stubs( :store )
    Dir.stubs( :chdir )
    File.stubs( :umask )
    STDIN.stubs( :reopen )
    STDOUT.stubs( :reopen )
    STDERR.stubs( :reopen )
    Daemon::Controller.stubs( :trap )

    @drb_threads.stubs( :join )
    DRb.stubs( :thread ).returns( @drb_threads )

    LucieDaemon.daemonize

    @remote_lucie_daemon = DRbObject.new_with_uri( LucieDaemon.uri )
  end
end


# As a Lucie commandline script,
# I want to delegate jobs to root privileged Lucie daemon via druby protocol,
# so that I can be executed without root privilege.

describe LucieDaemon, 'when calling sudo via druby' do
  it_should_behave_like 'Lucie Daemon (daemon disabled)'


  after( :each ) do
    DRb.stop_service
  end


  it 'should raise RuntimeError if invalid command is executed' do
    File.stubs( :open ).with( 'LOG_FILE', 'w' ).returns( StringIO.new( '' ) )

    # when
    lambda do
      @remote_lucie_daemon.sudo( 'INVALID_COMMAND', 'LOG_FILE' )
    end.should raise_error( RuntimeError )

    # then
    verify_mocks
  end


  it 'should execute pwd command without errors' do
    log = Object.new
    File.stubs( :open ).with( 'LOG_FILE', 'w' ).returns( log )

    # expects
    Lucie::Log.expects( :info )
    log.expects( :puts )
    log.expects( :close )

    # when
    lambda do
      @remote_lucie_daemon.sudo( 'pwd', 'LOG_FILE' )

      # then
    end.should_not raise_error
  end


  it 'should log command output' do
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
    log.expects( :puts ).at_least_once
    log.expects( :close ).at_least_once

    # when
    lambda do
      @remote_lucie_daemon.sudo( 'COMMAND', 'LOG_FILE' )

      # then
    end.should_not raise_error
  end
end


describe LucieDaemon, 'when calling enable_node via druby' do
  it_should_behave_like 'Lucie Daemon (daemon disabled)'


  after( :each ) do
    DRb.stop_service
  end


  it 'should disable a node if Lucie daemon is started' do
    enable_node_task = Object.new

    # expects
    Rake::Task.expects( :[] ).with( 'lucie:enable_node' ).returns( enable_node_task )
    enable_node_task.expects( :execute )

    # when
    @remote_lucie_daemon.enable_node( 'NODE_NAME', 'INSTALLER_NAME', true )

    # then
    verify_mocks
  end
end


describe LucieDaemon, 'when calling disable_node via druby' do
  it_should_behave_like 'Lucie Daemon (daemon disabled)'


  after( :each ) do
    DRb.stop_service
  end


  it 'should disable a node if Lucie daemon is started' do
    node = Object.new

    # expects
    Nodes.expects( :find ).with( 'NODE_NAME' ).returns( node )
    node.expects( :disable! )
    Tftp.expects( :disable ).with( 'NODE_NAME' )

    # when
    @remote_lucie_daemon.disable_node( 'NODE_NAME' )

    # then
    verify_mocks
  end


  it 'should raise if node is not added' do
    # expects
    Nodes.expects( :find ).with( 'NODE_NAME' )

    # when
    lambda do
      @remote_lucie_daemon.disable_node( 'NODE_NAME' )

      # then
    end.should raise_error( RuntimeError, 'Node NODE_NAME not found!' )
    verify_mocks
  end
end


# As a 'node install' command,
# I want to delegate restart process of Puppet daemon to root privileged Lucie daemon via druby protocol,
# so that I can restart Puppet daemon without root privilege.

describe LucieDaemon, 'when calling restart_puppet via druby' do
  it_should_behave_like 'Lucie Daemon (daemon disabled)'


  after( :each ) do
    DRb.stop_service
  end


  it 'should restart Puppet daemon if Lucie daemon is started' do
    # expects
    PuppetController.expects( :restart )

    # when
    @remote_lucie_daemon.restart_puppet

    # then
    verify_mocks
  end


  it 'should fail to restart Puppet daemon if Lucie daemon is not started yet' do
    # given
    DRb.stop_service

    lambda do
      # when
      @remote_lucie_daemon.restart_puppet

      # then
    end.should raise_error
  end
end
