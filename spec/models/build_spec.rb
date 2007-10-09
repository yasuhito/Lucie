require File.dirname( __FILE__ ) + '/../spec_helper'


describe "All Builds", :shared => true do
  def with_sandbox_installer &block
    in_total_sandbox do | sandbox |
      FileUtils.mkdir_p( "#{ sandbox.root }/work" )

      installer = Installer.new( 'my_installer' )
      installer.path = sandbox.root

      yield sandbox, installer
    end
  end
end


describe Build do
  it_should_behave_like 'All Builds'


  it 'should grab log file' do
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => "build-1/build.log", :with_content => 'BUILD_LOG'
      build = Build.new( installer, 1 )

      build.output.should == 'BUILD_LOG'
    end
  end


  it 'should have empty installer settings when no config was found' do
    with_sandbox_installer do | sandbox, installer |
      build = Build.new( installer, 123 )

      File.stubs( :open ).raises( RuntimeError )

      build.installer_settings.should == ''
    end
  end


  it 'should store settings' do
    with_sandbox_installer do | sandbox, installer |
      installer.stubs( :config_file_content ).returns( 'COOL INSTALLER SETTINGS' )

      build = Build.new( installer, 123 )
      build.stubs :execute

      lambda {
        build.run
      }.should_not raise_error

      File.open( 'build-123/lucie_config.rb', 'r' ) do | file |
        file.read.should == 'COOL INSTALLER SETTINGS'
      end
      Build.new( installer, 123 ).installer_settings.should == 'COOL INSTALLER SETTINGS'
    end
  end


  it 'should have changeset' do
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-123/changeset.log', :with_content => 'TIMESTAMP'

      Build.new( installer, 123 ).changeset.should == 'TIMESTAMP'
    end
  end


  it 'should have status' do
    with_sandbox_installer do | sandbox, installer |
      BuildStatus.any_instance.expects( :to_s )

      lambda {
        Build.new( installer, 123 ).status
      }.should_not raise_error
    end
  end


  it 'should have timestamp' do
    with_sandbox_installer do | sandbox, installer |
      BuildStatus.any_instance.expects( :timestamp ).returns( 'TIMESTAMP' )

      Build.new( installer, 123 ).time.should == 'TIMESTAMP'
    end
  end


  it 'should call default rake task' do
    with_sandbox_installer do | sandbox, installer |
      build_with_defaults = Build.new( installer, '1' )
      build_with_defaults.command.should match( /installer_build.rake';.* 'installer:build'/ )
      build_with_defaults.rake_task.should be_nil
    end
  end


  it 'should be customizable with custom rake task' do
    with_sandbox_installer do | sandbox, installer |
      installer.rake_task = 'my_build_task'
      build_with_custom_rake_task = Build.new( installer, '2' )
      build_with_custom_rake_task.command.should match( /installer_build.rake';.* 'installer:build'/ )
      build_with_custom_rake_task.rake_task.should == 'my_build_task'
    end
  end


  it 'should be customizable with custom script' do
    with_sandbox_installer do | sandbox, installer |
      installer.rake_task = nil
      installer.build_command = 'my_build_script.sh'
      build_with_custom_script = Build.new( installer, '3' )
      build_with_custom_script.command.should == 'my_build_script.sh'
      build_with_custom_script.rake_task.should be_nil
    end
  end


  it 'should know about additional artifacts' do
    with_sandbox_installer do | sandbox, installer |
      # additional artifacts
      sandbox.new :file => 'build-1/coverage/index.html'
      sandbox.new :file => 'build-1/coverage/units/index.html'
      sandbox.new :file => 'build-1/coverage/functionals/index.html'
      sandbox.new :file => 'build-1/foo'
      sandbox.new :file => 'build-1/foo.txt'

      # artifacts
      sandbox.new :file => 'build-1/lucie_config.rb'
      sandbox.new :file => 'build-1/plugin_errors.log'
      sandbox.new :file => 'build.log'
      sandbox.new :file => 'build_status.failure'
      sandbox.new :file => 'changeset.log'

      build = Build.new( installer, 1 )
      build.additional_artifacts.sort.should == %w(coverage foo foo.txt)
    end
  end


  it 'should generate build url using dashboard_url' do
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-1/build_status.success.in0s'
      build = Build.new( installer, 1 )
      Configuration.expects( :dashboard_url ).returns( dashboard_url )

      build.url.should == "#{ dashboard_url }/builds/#{ installer.name }/#{ build.to_param }"
    end
  end


  it 'should fail generating url when dashboard_url is not specifiled' do
    with_sandbox_installer do | sandbox, installer |
      build = Build.new( installer, 1 )
      Configuration.expects( :dashboard_url ).returns( nil )

      assert_raise( RuntimeError ) do
        build.url
      end
    end
  end


  it 'should get empty string when log file does not exist' do
    with_sandbox_installer do | sandbox, installer |
      File.expects( :open ).with( "#{ installer.path }/build-1/build.log", 'r' ).raises( StandardError )
      Build.new( installer, 1 ).output.should == ''
    end
  end


  def dashboard_url
    'http://www.my.com'
  end
end


describe Build, ' (never built)' do
  it_should_behave_like 'All Builds'


  it 'should load status file' do
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-2/build_status.something'

      Build.new( installer, 1 ).status.should == 'never_built'
    end
  end
end


describe Build, ' (incomplete)' do
  it_should_behave_like 'All Builds'


  it 'should be incomplete' do
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-1/build_status.incomplete'

      Build.new( installer, 1 ).should be_incomplete
    end
  end


  it 'should have elapsed_time_in_progress' do
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-123/build_status.incomplete'

      assert_in_delta 1.0, Build.new( installer, 123 ).elapsed_time_in_progress, 2
    end
  end
end


describe Build, ' (success)' do
  it_should_behave_like 'All Builds'


  it 'should load success build status file' do
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-1/build_status.success'
      sandbox.new :file => 'build-2/build_status.Success'
      sandbox.new :file => 'build-3/build_status.failure'
      sandbox.new :file => 'build-4/build_status.crap'
      sandbox.new :file => 'build-5/foo'

      Build.new( installer, 1 ).should be_successful
      Build.new( installer, 2 ).should be_successful
      Build.new( installer, 3 ).should_not be_successful
      Build.new( installer, 4 ).should_not be_successful
      Build.new( installer, 5 ).should_not be_successful
    end
  end


  it 'should run successful build' do
    with_sandbox_installer do | sandbox, installer |
      expected_build_directory = File.join( sandbox.root, 'build-123' )

      build = Build.new( installer, 123 )

      expected_build_log = File.join( expected_build_directory, 'build.log' )
      expected_redirect_options = {
        :stdout => expected_build_log,
        :stderr => expected_build_log,
        :escape_quotes => false
      }
      Time.expects( :now ).at_least( 2 ).returns( Time.at( 0 ), Time.at( 3.2 ) )
      build.expects( :execute ).with( build.rake, expected_redirect_options )

      BuildStatus.any_instance.expects( :start! )
      BuildStatus.any_instance.expects( :succeed! ).with( 4 )
      BuildStatus.any_instance.expects( :fail! ).never

      lambda {
        build.run
      }.should_not raise_error
    end
  end
end


describe Build, ' (fail)' do
  it_should_behave_like 'All Builds'


  it 'should load fail build status file' do
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-2/build_status.failed.in2s'
      build = Build.new( installer, 2 )

      assert_equal true, build.failed?
    end
  end


  it 'should run unsuccessful build' do
    with_sandbox_installer do | sandbox, installer |
      expected_build_directory = File.join( sandbox.root, 'build-123' )

      build = Build.new( installer, 123 )

      expected_build_log = File.join( expected_build_directory, 'build.log' )
      expected_redirect_options = {
        :stdout => expected_build_log,
        :stderr => expected_build_log,
        :escape_quotes => false
      }

      build.expects( :execute ).with( build.rake, expected_redirect_options ).raises( CommandLine::ExecutionError )
      Time.stubs( :now ).returns( Time.at( 1 ) )
      BuildStatus.any_instance.expects( :start! )
      BuildStatus.any_instance.expects( :fail! ).with( 0 )

      lambda {
        build.run
      }.should_not raise_error
    end
  end


  it 'should fail if lucie config is invalid' do
    with_sandbox_installer do | sandbox, installer |
      expected_build_directory = File.join( sandbox.root, 'build-123' )
      installer.stubs( :config_file_content ).returns( 'COOL INSTALLER SETTINGS' )
      installer.stubs( :error_message ).returns( 'SOME INSTALLER CONFIG ERROR' )
      installer.expects( :config_valid? ).returns( false )

      build = Build.new( installer, 123 )
      build.run

      build.should be_failed

      log_message = File.open( 'build-123/build.log' ) do | file |
        file.read
      end
      log_message.should == 'SOME INSTALLER CONFIG ERROR'
    end
  end


  it 'should pass error to build status if config file is invalid' do
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-1/build.log'
      installer.stubs( :error_message ).returns( 'FAIL MESSAGE' )
      installer.stubs( :config_valid? ).returns( false )

      build = Build.new( installer, 1 )
      build.run

      fail_message = File.open( 'build-1/build_status.failed.in0s' ) do | file |
        file.read
      end
      fail_message.should == 'FAIL MESSAGE'
      build.brief_error.should == 'config error'
    end
  end


  it 'should have no error info if error is unknown' do
    with_sandbox_installer do | sandbox, installer |
      sandbox.new :file => 'build-1/build_status.success.in0s'

      build = Build.new( installer, 1 )
      build.stubs( :plugin_errors ).returns( [] )

      build.brief_error.should be_nil
    end
  end
end
