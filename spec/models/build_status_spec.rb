require File.dirname( __FILE__ ) + '/../spec_helper'


describe BuildStatus, ' when handling timestamp' do
  it 'should give creation time for status_file' do
    now = Time.now
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [ :some_file ] )
    File.stubs( :mtime ).with( :some_file ).returns( now )

    BuildStatus.new( 'artifacts_directory' ).created_at.should == now
  end


  it 'should give newer mtime of build log and artifacts dir' do
    newer_mtime = Time.now
    older_mtime = 2.days.ago
    File.stubs( :mtime ).with( 'artifacts_directory/build.log' ).returns( newer_mtime )
    File.stubs( :mtime ).with( 'artifacts_directory' ).returns( older_mtime )

    BuildStatus.new( 'artifacts_directory' ).timestamp.should == newer_mtime

    File.stubs( :mtime ).with( 'artifacts_directory/build.log' ).returns( older_mtime )
    File.stubs( :mtime ).with( 'artifacts_directory' ).returns( newer_mtime )

    BuildStatus.new( 'artifacts_directory' ).timestamp.should == newer_mtime
  end


  it 'should give mtime of artifacts dir if build_log not exist' do
    build_dir_mtime = Time.now
    File.stubs( :mtime ).with( 'artifacts_directory' ).returns( build_dir_mtime )
    File.stubs( :mtime ).with( 'artifacts_directory/build.log' ).raises

    BuildStatus.new( 'artifacts_directory' ).timestamp.should == build_dir_mtime
  end


  it 'should give nil when artifacts file not exist' do
    Dir.expects( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [] )

    BuildStatus.new( 'artifacts_directory' ).created_at.should be_nil
  end
end


describe BuildStatus, ' when converting to String' do
  it 'should be never_built' do
    BuildStatus.new( 'artifacts_directory' ).to_s.should == 'never_built'
  end


  it 'should be incomplete' do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [ 'build_status.incomplete' ] )

    BuildStatus.new( 'artifacts_directory' ).to_s.should == 'incomplete'
  end


  it 'should be success' do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [ 'build_status.success' ] )

    BuildStatus.new( 'artifacts_directory' ).to_s.should == 'success'
  end


  it 'should be failed' do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [ 'build_status.failed' ] )

    BuildStatus.new( 'artifacts_directory' ).to_s.should == 'failed'
  end
end


describe BuildStatus, " when calling '!' methods" do
  it 'should create success file' do
    Dir.stubs( :[] ).returns( [ 'artifacts_directory/build_status.foo' ] )
    FileUtils.expects( :rm_f ).with( [ 'artifacts_directory/build_status.foo' ] )
    FileUtils.expects( :touch ).with( 'artifacts_directory/build_status.success.in3.5s' )

    lambda do
      BuildStatus.new( 'artifacts_directory' ).succeed!( 3.5 )
    end.should_not raise_error
  end


  it 'should create fail file' do
    Dir.stubs( :[] ).returns( [ 'artifacts_directory/build_status.foo' ] )
    FileUtils.expects( :rm_f ).with( [ 'artifacts_directory/build_status.foo' ] )
    FileUtils.expects( :touch ).with( 'artifacts_directory/build_status.failed.in3.5s' )
    file = Object.new
    file.expects( :write ).with( 'ERROR_MESSAGE' )
    File.expects( :open ).with( 'artifacts_directory/build_status.failed.in3.5s', 'w' ).yields( file )

    lambda do
      BuildStatus.new( 'artifacts_directory' ).fail!( 3.5, 'ERROR_MESSAGE' )
    end.should_not raise_error
  end
end


describe BuildStatus, ' when getting status' do
  it "should be 'never built' when build_status file is missing" do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [] )

    BuildStatus.new( 'artifacts_directory' ).should be_never_built
  end


  it "should NOT be 'never built' when build_status file exists" do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [ 'build_status.anything' ] )

    BuildStatus.new( 'artifacts_directory' ).should_not be_never_built
  end


  it 'should give succeeded status' do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [ 'build_status.success' ] )

    BuildStatus.new( 'artifacts_directory' ).should be_succeeded
  end


  it 'should give failed status' do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [ 'build_status.failed.in3.5s' ] )

    BuildStatus.new( 'artifacts_directory' ).should be_failed
  end


  it 'should NOT give failed status when build_status file is NOT failed' do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [] )

    BuildStatus.new( 'artifacts_directory' ).should_not be_failed
  end


  it 'should NOT give succeeded status when build_status file is NOT success' do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [] )

    BuildStatus.new( 'artifacts_directory' ).should_not be_succeeded
  end
end


describe BuildStatus, ' when getting elapsed time (build completed)' do
  it 'should parse elapsed time' do
    BuildStatus.new( '' ).match_elapsed_time( 'build_status.success.in10s' ).should == 10
    BuildStatus.new( '' ).match_elapsed_time( 'build_status.failed.in760s' ).should == 760
  end


  it 'should raise exception when elapsed time not parsable' do
    assert_exception_when_parsing_elapsed_time( 'build_status.failed' )
    assert_exception_when_parsing_elapsed_time( 'build_status.success' )
    assert_exception_when_parsing_elapsed_time( 'build_status.failed?' )
  end


  it 'should give elapsed time' do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [ 'build_status.success.in3s' ] )

    BuildStatus.new( 'artifacts_directory' ).elapsed_time.should == 3
  end


  it 'should raise if elapsed time not available' do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [ 'build_status.FOO' ] )

    lambda do
      BuildStatus.new( 'artifacts_directory' ).elapsed_time
    end.should raise_error
  end



  def assert_exception_when_parsing_elapsed_time file_name
    lambda do
      BuildStatus.new( '' ).match_elapsed_time file_name
    end.should raise_error
  end
end


describe BuildStatus, ' when getting elapsed time (build in progress)' do
  it 'should give elapsed time' do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [ 'build_status.incomplete' ] )
    File.stubs( :mtime ).with( 'build_status.incomplete' ).returns( mtime )
    Time.stubs( :now ).returns( mtime + 9 )

    BuildStatus.new( 'artifacts_directory' ).elapsed_time_in_progress.should == 9
  end


  it 'should not give elapsed time when build completed' do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [ 'build_status.success.in123s' ] )

    BuildStatus.new( 'artifacts_directory' ).elapsed_time_in_progress.should be_nil
  end


  it 'should ceil elapsed time' do
    Dir.stubs( :[] ).with( 'artifacts_directory/build_status.*' ).returns( [ 'build_status.incomplete' ] )
    File.stubs( :mtime ).with( 'build_status.incomplete' ).returns( mtime )
    Time.stubs( :now ).returns( mtime + 9.2 )

    BuildStatus.new( 'artifacts_directory' ).elapsed_time_in_progress.should == 10
  end


  def mtime
    Time.local( 2000, 'jan', 1, 20, 15, 1 )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
