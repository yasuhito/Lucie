require File.dirname( __FILE__ ) + '/../spec_helper'


# As a Lucie commandline script,
# I want to start daemonized druby server (Lucie daemon),
# so that I can always delegate jobs to Lucie daemon.

describe LucieDaemon, 'when starting Lucie daemon' do
  it 'should be daemonized and druby enabled' do
    @lucie_daemon = LucieDaemon.new
    @drb_threads = Object.new
    LucieDaemon.stubs( :new ).returns( @lucie_daemon )

    # expects
    Daemon::Controller.expects( :fork ).yields.times( 2 ).returns( false )
    Process.expects( :setsid )
    Daemon::PidFile.expects( :store )
    Dir.expects( :chdir )
    File.expects( :umask )
    STDIN.expects( :reopen )
    STDOUT.expects( :reopen )
    STDERR.expects( :reopen )
    Daemon::Controller.expects( :trap )

    DRb.expects( :start_service ).with( 'druby://localhost:58243', @lucie_daemon )
    @drb_threads.expects( :join )
    DRb.expects( :thread ).returns( @drb_threads )

    # when
    LucieDaemon.daemonize

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
    Daemon::PidFile.stubs( :store )
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
    # when
    lambda do
      @remote_lucie_daemon.sudo( 'INVALID_COMMAND' )
    end.should raise_error( RuntimeError )

    # then
    verify_mocks
  end


  it 'should execute pwd command without errors' do
    # when
    lambda do
      @remote_lucie_daemon.sudo( 'pwd 2>&1 >/dev/null' )

      # then
    end.should_not raise_error
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
    Puppet.expects( :restart )

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
