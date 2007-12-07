require File.dirname( __FILE__ ) + '/../spec_helper'


describe 'All InstallerBlockers', :shared => true do
  before( :each ) do
    @installer_stub = Object.new
    @installer_stub.stubs( :path ).returns( 'DUMMY_PATH' )
    @installer_stub.stubs( :name ).returns( 'DUMMY_INSTALLER' )

    @lock_mock = mock( 'LOCK' )

    @pid_file_path = File.expand_path( './DUMMY_PATH/builder.pid' )
  end


  def clear_pid_files
    InstallerBlocker.pid_files = { }
  end
end


# As a builder script,
# I want to block other builders while I am building a installer
# So that builders do not conflict each other.

describe InstallerBlocker, 'when calling block' do
  it_should_behave_like 'All InstallerBlockers'


  it 'should create PID file if there is no other PID file' do
    # given
    clear_pid_files

    # expects
    File.expects( :open ).with( @pid_file_path, 'w' ).returns( @lock_mock )
    @lock_mock.expects( :flock ).with( File::LOCK_EX | File::LOCK_NB ).returns( 'LOCKED' )

    # when
    InstallerBlocker.block @installer_stub

    # then
    verify_mocks
  end


  it 'should fail to create PID file if same PID file already exists' do
    # given
    InstallerBlocker.pid_files = { @pid_file_path => true }

    lambda do
      # when
      InstallerBlocker.block @installer_stub

      # then
    end.should raise_error( RuntimeError, "Already holding a lock on installer 'DUMMY_INSTALLER'" )
  end


  it 'should fail to lock if failed to flock' do
    clear_pid_files
    File.stubs( :open ).returns( @lock_mock )

    # given
    @lock_mock.stubs( :flock ).returns( false )

    # expects
    @lock_mock.expects( :close )

    lambda do
      # when
      InstallerBlocker.block @installer_stub

      # then
    end.should raise_error( RuntimeError,  "Another process (probably another builder) holds a lock on installer 'DUMMY_INSTALLER'.\n" + "Look for a process with a lock on file #{ @pid_file_path }" )

    # and
    verify_mocks
  end
end


# As a builder script,
# I want to determine an installer is blocked or not
# So that I can handle each cases.

describe InstallerBlocker, 'when calling blocked?' do
  it_should_behave_like 'All InstallerBlockers'


  it 'should return true if PID file is already created' do
    # given
    InstallerBlocker.pid_files = { @pid_file_path => true }

    # when
    result = InstallerBlocker.blocked?( @installer_stub )

    # then
    result.should be_true
  end


  it 'should return true if InstallerBlocker does not know existing flocked PID file' do
    File.stubs( :open ).returns( @lock_mock )

    # given
    clear_pid_files

    # expects
    @lock_mock.expects( :flock ).with( File::LOCK_EX | File::LOCK_NB ).returns( false )
    @lock_mock.expects( :flock ).with( File::LOCK_UN | File::LOCK_NB )
    @lock_mock.expects( :close )

    # when
    result = InstallerBlocker.blocked?( @installer_stub )

    # then
    result.should be_true
    verify_mocks
  end


  it 'should return false if InstallerBlocker does not know existing PID file which is not flocked' do
    File.stubs( :open ).returns( @lock_mock )

    # given
    clear_pid_files

    # expects
    @lock_mock.expects( :flock ).with( File::LOCK_EX | File::LOCK_NB ).returns( true )
    @lock_mock.expects( :flock ).with( File::LOCK_UN | File::LOCK_NB )
    @lock_mock.expects( :close )

    # when
    result = InstallerBlocker.blocked?( @installer_stub )

    # then
    result.should be_false
    verify_mocks
  end
end


# As a builder script
# I want to release a lock
# So that I can cleanup installer build environment

describe InstallerBlocker, 'when calling release' do
  it_should_behave_like 'All InstallerBlockers'


  it 'should unlock and delete the lock file' do
    InstallerBlocker.stubs( :pid_file ).returns( 'PID_FILE' )

    # given
    InstallerBlocker.pid_files = { 'PID_FILE' => @lock_mock }

    # expects
    @lock_mock.expects( :flock ).with( File::LOCK_UN | File::LOCK_NB )
    @lock_mock.expects( :close )
    @lock_mock.expects( :path ).returns( 'DUMMY_LOCK_PATH' )
    File.expects( :delete ).with( 'DUMMY_LOCK_PATH' )

    # when
    InstallerBlocker.release @installer_stub

    # then
    verify_mocks
  end
end
