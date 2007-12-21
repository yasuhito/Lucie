require File.dirname( __FILE__ ) + '/../spec_helper'


# As a Installer
# I want to delegate build of installers to root privileged LucieDaemon process via druby protocol
# So that only LucieDaemon should run in root privilege

describe LucieDaemon, 'when calling sudo' do
  before( :each ) do | each |
    @lucie_daemon = LucieDaemon.new
  end


  it 'should run command with root privilege' do
    # expects
    @lucie_daemon.expects( :execute ).with( 'DUMMY_COMMAND' )

    # when
    @lucie_daemon.sudo( 'DUMMY_COMMAND' )

    # then
    verify_mocks
  end


  it 'should call block with root privilege' do
    # expects
    @dummy_object.expects( :hello )

    # when
    @lucie_daemon.sudo do
      @dummy_object.hello
    end

    # then
    verify_mocks
  end
end


# As a lucie commandline script,
# I want to start druby lucie server
# So that Lucie scripts can delegate operations to Lucie daemon via druby

describe LucieDaemon, 'when starting Lucie daemon' do
  it 'should start with druby enabled' do
    @lucie_daemon = LucieDaemon.new
    LucieDaemon.stubs( :new ).returns( @lucie_daemon )

    # expects
    DRb.expects( :start_service ).with( 'druby://localhost:58243', @lucie_daemon )

    # when
    LucieDaemon.start_service

    # then
    verify_mocks
  end
end


# As a 'node install' command,
# I want to make sure LucieDaemon can handle restart of Puppet daemon
# so that I can delegate restart of Puppet daemon to LucieDaemon object

describe LucieDaemon, 'when calling restart_puppet' do
  it 'should restart Puppet daemon' do
    # expects
    Puppet.expects( :restart )

    # when
    LucieDaemon.new.restart_puppet

    # then
    verify_mocks
  end
end


describe LucieDaemon, 'when calling sudo via druby' do
  before( :each ) do
    LucieDaemon.start_service
    @remote_lucie_daemon = DRbObject.new_with_uri( LucieDaemon.uri )
  end


  after( :each ) do
    DRb.stop_service
  end


  it 'should raise CommandLine::ExecutionError if invalid command is executed' do
    # when
    lambda do
      @remote_lucie_daemon.sudo( 'hoge' )
    end.should raise_error( CommandLine::ExecutionError )

    # then
    verify_mocks

  end


  it 'should execute pwd command' do
    # when
    lambda do
      @remote_lucie_daemon.sudo( 'pwd' )
    end.should_not raise_error
  end


  it 'should execute code block' do
    # expects
    io = Object.new
    io.expects( :puts ).with( 'hello' )

    # when
    lambda do
      @remote_lucie_daemon.sudo do
        io.puts "hello"
      end
    end.should_not raise_error
  end
end


# As a 'node install' command,
# I want to delegate restart of Puppet daemon to root privileged LucieDaemon process via druby protocol
# so that I can restart Puppet daemon without root privileges

describe LucieDaemon, 'when calling restart_puppet via druby' do
  after( :each ) do
    DRb.stop_service
  end


  it 'should fail to restart Puppet daemon if Lucie daemon is not started yet' do
    # given
    DRb.stop_service

    lambda do
      # when
      remote_lucie_daemon = DRbObject.new_with_uri( LucieDaemon.uri )
      remote_lucie_daemon.restart_puppet

      # then
    end.should raise_error

    # and
    verify_mocks
  end


  it 'should restart Puppet daemon if Lucie daemon is started' do
    # given
    LucieDaemon.start_service

    # expects
    Puppet.expects( :restart )

    # when
    remote_lucie_daemon = DRbObject.new_with_uri( LucieDaemon.uri )
    remote_lucie_daemon.restart_puppet

    # then
    verify_mocks
  end
end
