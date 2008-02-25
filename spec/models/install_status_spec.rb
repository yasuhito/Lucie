require File.dirname( __FILE__ ) + '/../spec_helper'


describe InstallStatus, ' when handling timestamp' do
  it 'should give newer mtime of install log and artifacts dir' do
    newer_mtime = Time.now
    older_mtime = 2.days.ago
    File.stubs( :mtime ).with( 'artifacts_directory/install.log' ).returns( newer_mtime )
    File.stubs( :mtime ).with( 'artifacts_directory' ).returns( older_mtime )

    InstallStatus.new( 'artifacts_directory' ).timestamp.should == newer_mtime

    File.stubs( :mtime ).with( 'artifacts_directory/install.log' ).returns( older_mtime )
    File.stubs( :mtime ).with( 'artifacts_directory' ).returns( newer_mtime )

    InstallStatus.new( 'artifacts_directory' ).timestamp.should == newer_mtime
  end


  it 'should give mtime of artifacts dir if install_log not exist' do
    install_dir_mtime = Time.now
    File.stubs( :mtime ).with( 'artifacts_directory' ).returns( install_dir_mtime )
    File.stubs( :mtime ).with( 'artifacts_directory/install.log' ).raises

    InstallStatus.new( 'artifacts_directory' ).timestamp.should == install_dir_mtime
  end
end


describe InstallStatus, ' when converting to String' do
  it 'should be incomplete' do
    Dir.stubs( :[] ).with( 'artifacts_directory/install_status.*' ).returns( [ 'install_status.incomplete' ] )

    InstallStatus.new( 'artifacts_directory' ).to_s.should == 'incomplete'
  end


  it 'should be success' do
    Dir.stubs( :[] ).with( 'artifacts_directory/install_status.*' ).returns( [ 'install_status.success' ] )

    InstallStatus.new( 'artifacts_directory' ).to_s.should == 'success'
  end


  it 'should be failed' do
    Dir.stubs( :[] ).with( 'artifacts_directory/install_status.*' ).returns( [ 'install_status.failed' ] )

    InstallStatus.new( 'artifacts_directory' ).to_s.should == 'failed'
  end
end


describe InstallStatus, " when doing destructive operations" do
  it 'should create success file' do
    Dir.stubs( :[] ).returns( [ 'artifacts_directory/install_status.foo' ] )
    FileUtils.expects( :rm_f ).with( [ 'artifacts_directory/install_status.foo' ] )
    FileUtils.expects( :touch ).with( 'artifacts_directory/install_status.success.in3.5s' )

    lambda do
      InstallStatus.new( 'artifacts_directory' ).succeed!( 3.5 )
    end.should_not raise_error
  end


  it 'should create fail file' do
    Dir.stubs( :[] ).returns( [ 'artifacts_directory/install_status.foo' ] )
    FileUtils.expects( :rm_f ).with( [ 'artifacts_directory/install_status.foo' ] )
    FileUtils.expects( :touch ).with( 'artifacts_directory/install_status.failed.in3.5s' )
    file = Object.new
    file.expects( :write ).with( 'ERROR_MESSAGE' )
    File.expects( :open ).with( 'artifacts_directory/install_status.failed.in3.5s', 'w' ).yields( file )

    lambda do
      InstallStatus.new( 'artifacts_directory' ).fail!( 3.5, 'ERROR_MESSAGE' )
    end.should_not raise_error
  end


  it 'should create incomplete file' do
    Dir.stubs( :[] ).returns( [ 'artifacts_directory/install_status.foo' ] )
    FileUtils.expects( :rm_f ).with( [ 'artifacts_directory/install_status.foo' ] )
    FileUtils.expects( :touch ).with( 'artifacts_directory/install_status.incomplete' )

    lambda do
      InstallStatus.new( 'artifacts_directory' ).start!
    end.should_not raise_error
  end
end


describe InstallStatus, ' when getting status' do
  it 'should give succeeded status' do
    Dir.stubs( :[] ).with( 'artifacts_directory/install_status.*' ).returns( [ 'install_status.success' ] )

    InstallStatus.new( 'artifacts_directory' ).should be_succeeded
  end


  it 'should give failed status' do
    Dir.stubs( :[] ).with( 'artifacts_directory/install_status.*' ).returns( [ 'install_status.failed.in3.5s' ] )

    InstallStatus.new( 'artifacts_directory' ).should be_failed
  end


  it 'should give incomplete status' do
    Dir.stubs( :[] ).with( 'artifacts_directory/install_status.*' ).returns( [ 'install_status.incomplete' ] )

    InstallStatus.new( 'artifacts_directory' ).should be_incomplete
  end


  it 'should NOT give failed status when install_status file is NOT failed' do
    Dir.stubs( :[] ).with( 'artifacts_directory/install_status.*' ).returns( [] )

    InstallStatus.new( 'artifacts_directory' ).should_not be_failed
  end


  it 'should NOT give succeeded status when install_status file is NOT success' do
    Dir.stubs( :[] ).with( 'artifacts_directory/install_status.*' ).returns( [] )

    InstallStatus.new( 'artifacts_directory' ).should_not be_succeeded
  end
end


describe InstallStatus, ' when getting elapsed time (install completed)' do
  it 'should parse elapsed time' do
    InstallStatus.new( '' ).match_elapsed_time( 'install_status.success.in10s' ).should == 10
    InstallStatus.new( '' ).match_elapsed_time( 'install_status.failed.in760s' ).should == 760
  end


  it 'should raise exception when elapsed time not parsable' do
    assert_exception_when_parsing_elapsed_time( 'install_status.failed' )
    assert_exception_when_parsing_elapsed_time( 'install_status.success' )
    assert_exception_when_parsing_elapsed_time( 'install_status.failed?' )
  end


  it 'should give elapsed time' do
    Dir.stubs( :[] ).with( 'artifacts_directory/install_status.*' ).returns( [ 'install_status.success.in3s' ] )

    InstallStatus.new( 'artifacts_directory' ).elapsed_time.should == 3
  end


  it 'should raise if elapsed time not available' do
    Dir.stubs( :[] ).with( 'artifacts_directory/install_status.*' ).returns( [ 'install_status.FOO' ] )

    lambda do
      InstallStatus.new( 'artifacts_directory' ).elapsed_time
    end.should raise_error
  end



  def assert_exception_when_parsing_elapsed_time file_name
    lambda do
      InstallStatus.new( '' ).match_elapsed_time file_name
    end.should raise_error
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
