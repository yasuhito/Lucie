require File.dirname( __FILE__ ) + '/../spec_helper'


describe 'All LuciedBlockers', :shared => true do
  before( :each ) do
    @lock_mock = mock( 'LOCK' )
    @pid_file_path = File.expand_path( "#{ RAILS_ROOT }/tmp/pids/lucied.pid" )
    begin
      File.delete @pid_file_path
    rescue
    end
  end
end


# As a lucie command
# I want to block other lucied process while a lucied is running.
# So that multiple lucieds does not conflict each other.

describe LuciedBlocker, 'when calling block' do
  it_should_behave_like 'All LuciedBlockers'


  it 'should create PID file if there is no other lucied' do
    # expects
    File.expects( :open ).with( @pid_file_path, 'w' ).returns( @lock_mock )
    @lock_mock.expects( :flock ).with( File::LOCK_EX | File::LOCK_NB ).returns( 'LOCKED' )

    # when
    LuciedBlocker.block

    # then
    verify_mocks
  end


  it 'should fail to create PID file if other lucied already exists' do
    lambda do
      # given
      LuciedBlocker.block

      # when
      LuciedBlocker.block

      # then
    end.should raise_error( RuntimeError, 'Another lucied is already running.' )
  end


  it 'should fail to lock if failed to flock' do
    File.stubs( :open ).returns( @lock_mock )

    # given
    @lock_mock.stubs( :flock ).returns( false )

    # expects
    @lock_mock.expects( :close )

    lambda do
      # when
      LuciedBlocker.block

      # then
    end.should raise_error( RuntimeError,  'Another lucied is already running.' )

    # and
    verify_mocks
  end
end


# As a lucie command
# I want to determine an lucied is blocked or not
# So that I can handle each cases.

describe LuciedBlocker, 'when calling blocked?' do
  it_should_behave_like 'All LuciedBlockers'


  it 'should return true if PID file is already created' do
    # given
    LuciedBlocker.block

    # when
    result = LuciedBlocker.blocked?

    # then
    result.should be_true
  end


  it 'should return true if flocked PID file already exists' do
    # given
    FileTest.stubs( :exists? ).returns true
    File.stubs( :open ).returns( @lock_mock )

    # expects
    @lock_mock.expects( :flock ).with( File::LOCK_EX | File::LOCK_NB ).returns( false )
    @lock_mock.expects( :flock ).with( File::LOCK_UN | File::LOCK_NB )
    @lock_mock.expects( :close )

    # when
    @result = LuciedBlocker.blocked?

    # then
    @result.should be_true
    verify_mocks
  end


  it 'should return false if PID file does not exist' do
    # given
    FileTest.stubs( :exists? ).returns false

    # when
    @result = LuciedBlocker.blocked?

    # then
    @result.should be_false
    verify_mocks
  end


  it 'should return false if not flocked PID file exists' do
    # given
    FileTest.stubs( :exists? ).returns true
    File.stubs( :open ).returns( @lock_mock )

    # expects
    @lock_mock.expects( :flock ).with( File::LOCK_EX | File::LOCK_NB ).returns( true )
    @lock_mock.expects( :flock ).with( File::LOCK_UN | File::LOCK_NB )
    @lock_mock.expects( :close )

    # when
    @result = LuciedBlocker.blocked?

    # then
    @result.should be_false
    verify_mocks
  end
end


# As a lucie command
# I want to release a lock
# So that I can cleanup lucied

describe LuciedBlocker, 'when calling release' do
  it_should_behave_like 'All LuciedBlockers'


  it 'should unlock and delete the lock file' do
    LuciedBlocker.stubs( :pid_file ).returns( @pid_file_path )
    File.stubs( :open ).returns @lock_mock

    # expects
    @lock_mock.expects( :flock ).with( File::LOCK_UN | File::LOCK_NB )
    @lock_mock.expects( :close )
    @lock_mock.expects( :path ).returns( @pid_file_path )
    File.expects( :delete ).with( @pid_file_path )

    # when
    LuciedBlocker.release

    # then
    verify_mocks
  end
end


describe LuciedBlocker, 'when manipulating PID file' do
  it 'should store store pid' do
    file = StringIO.new( '' )

    # expects
    File.expects( :open ).yields( file )

    # when
    LuciedBlocker::PidFile.store( 'PID' )

    # then
    verify_mocks
  end


  it 'should recall pid' do
    # expects
    IO.expects( :read ).returns( '12345' )

    # when
    LuciedBlocker::PidFile.recall.should == 12345

    # then
    verify_mocks
  end
end
