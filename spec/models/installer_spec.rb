require File.dirname( __FILE__ ) + '/../spec_helper'


################################################################################
# Desctiptions for Installer.read
################################################################################


describe 'Installers read with Installer.read', :shared => true do
  include FileSandbox


  it 'should have a name equal to basename of installer_path' do
    @installer.name.should == File.basename( @installer_path )
  end


  it 'should have a path equal to installer_path' do
    @installer.path.should == @installer_path
  end


  it 'should have a installer config tracker' do
    @installer.config_tracker.should_not be_nil
  end


  it 'should have a scheduler' do
    @installer.scheduler.should_not be_nil
  end


  it 'should have a source control' do
    @installer.source_control.should_not be_nil
  end


  it 'should NOT have a default build command' do
    @installer.build_command.should be_nil
  end


  it 'should NOT have a default rake task' do
    @installer.rake_task.should be_nil
  end
end


# As a installer builder
# I want to load a installer object from installers/ directory
# So that I can build a installer.

describe Installer, 'when reading with Installer.read( installer_path, load_config = *FALSE* )' do
  it_should_behave_like 'Installers read with Installer.read'


  before( :each ) do
    in_sandbox do | sandbox |
      # Just create a DUMMY_INSTALLER/ directory.
      sandbox.new :file => 'DUMMY_INSTALLER/foobar'

      @installer_path = File.join( sandbox.root, 'DUMMY_INSTALLER' )
      @installer = Installer.read( @installer_path, load_config = false )
    end
  end


  it 'should have an empty installer setting' do
    @installer.settings.should be_empty
  end


  it 'should have an empty config' do
    @installer.config_file_content.should be_empty
  end
end


# As a installer builder
# I want to load a installer object from installers/ directory
# So that I can build a installer.

describe Installer, 'when reading with Installer.read( installer_path, load_config = *TRUE* )' do
  it_should_behave_like 'Installers read with Installer.read'


  before( :each ) do
    in_sandbox do | sandbox |
      sandbox.new :file => 'DUMMY_INSTALLER/work/lucie_config.rb', :with_contents => "key = 'value'"

      @installer_path = File.join( sandbox.root, 'DUMMY_INSTALLER' )
      @installer = Installer.read( @installer_path, load_config = true )
    end
  end


  it 'should have installer settings' do
    @installer.settings.should_not be_empty
  end


  it 'should keep contents of config file' do
    @installer.config_file_content.should_not be_empty
  end
end


# As a installer builder
# I want to load a installer object from installers/ directory
# So that I can build a installer.

describe Installer, 'when reading a broken installer with Installer.read' do
  it_should_behave_like 'Installers read with Installer.read'


  before( :each ) do
    Lucie::Log.stubs( :event )

    in_sandbox do | sandbox |
      sandbox.new :file => 'DUMMY_INSTALLER/work/lucie_config.rb', :with_contents => "class Invalid"

      @installer_path = File.join( sandbox.root, 'DUMMY_INSTALLER' )
      @installer = Installer.read( @installer_path )
    end
  end


  it 'should have an empty installer setting' do
    @installer.settings.should be_empty
  end


  it 'should keep contents of config file' do
    @installer.config_file_content.should_not be_empty
  end
end


# As a installer builder
# I want to request a build of installer
# so that I can build a installer

describe Installer, 'when calling request_build' do
  before( :each ) do
    in_sandbox do | sandbox |
      sandbox.new :file => 'DUMMY_INSTALLER/work/lucie_config.rb'

      installer_path = File.join( sandbox.root, 'DUMMY_INSTALLER' )
      @installer = Installer.read( installer_path, true )
    end

    @installer.stubs( :builder_state_and_activity ).returns( 'builder_down', 'builder_up' )
  end


  it 'should try to start builder and wait until builder is up' do
    @installer.stubs( :build_requested? ).returns( true )

    # expects
    BuilderStarter.expects( :begin_builder ).with( 'DUMMY_INSTALLER' )

    # when
    @installer.request_build

    # then
    verify_mocks
  end


  it 'should notify :build_requested and create a build_requested file if build_requested file does not exist' do
    # given
    @installer.stubs( :build_requested? ).returns( false )

    # expects
    @installer.expects( :notify ).with( :build_requested )
    @installer.expects( :create_build_requested_flag_file )

    # when
    @installer.request_build

    # then
    verify_mocks
  end
end


# As a installer,
# I want to remove build requested flag file when new revisions detected
# So that I should not re-enter build process.

describe Installer, 'when build requested with new revisions' do
  before( :each ) do
    @installer = Installer.new( 'DUMMY_INSTALLER' )
  end


  it 'should remove build requested flag file' do
    @installer.stubs( :build )

    # given
    @installer.stubs( :build_requested? ).returns( true )
    @installer.stubs( :new_revisions ).returns( [ 'DUMMY_NEW_REVISION' ] )

    # expects
    @installer.expects( :remove_build_requested_flag_file )

    # when
    @installer.build_if_necessary

    # then
    verify_mocks
  end
end


# As a installer scheduler,
# I want to request a build and to be notified succeeded or not
# So that I can enter polling loop that checks if build requested.

describe Installer, 'when :build_if_necessary called' do
  before( :each ) do
    @installer = Installer.new( 'DUMMY_INSTALLER' )
  end


  it 'should return nil if :now_new_revisions_detected' do
    # given
    @installer.stubs( :new_revisions ).returns( [] )

    # when
    result = @installer.build_if_necessary

    # then
    result.should be_nil
    verify_mocks
  end


  it 'should return a build if :new_revisions_detected' do
    # expects
    @installer.expects( :build ).with( [ 'DUMMY_NEW_REVISION' ] ).returns( 'DUMMY_BUILD' )

    # given
    @installer.stubs( :new_revisions ).returns( [ 'DUMMY_NEW_REVISION' ] )

    # when
    result = @installer.build_if_necessary

    # then
    result.should == 'DUMMY_BUILD'
    verify_mocks
  end
end


# As a builder plugin,
# I want to be notified installer related events when Installer#build_if_necessary called
# So that I can log events and set builder status.

describe Installer, 'when :build_if_necessary called' do
  before( :each ) do
    @installer = Installer.new( 'DUMMY_INSTALLER' )
    @listener = Object.new
    @installer.add_plugin @listener
  end


  it 'should generate a :no_new_revision_detected event if no new revisions' do
    # given
    @installer.stubs( :new_revisions ).returns( [] )

    # expects
    @listener.expects( :no_new_revisions_detected )

    # when
    @installer.build_if_necessary

    # then
    verify_mocks
  end


  it 'should generate :new_revisions_detected event if new revision found' do
    @installer.stubs( :build )
    revisions = [ Object.new ]

    # given
    @installer.stubs( :new_revisions ).returns( revisions )

    # expects
    @listener.expects( :new_revisions_detected ).with( revisions )

    # when
    @installer.build_if_necessary

    # then
    verify_mocks
  end


  it 'should generate :build_loop_failed event if build failed' do
    revisions = [ Object.new ]
    @installer.stubs( :new_revisions ).returns( revisions )

    # given
    build_error = StandardError.new
    @installer.stubs( :build ).raises( build_error )

    # expects
    @listener.expects( :build_loop_failed ).with( build_error )

    # when
    begin
      @installer.build_if_necessary
    rescue
      # do nothing
    end

    # then
    verify_mocks
  end


  it 'should generate :sleeping event if build succeessfully finished' do
    @installer.stubs( :new_revisions ).returns( [ Object.new ] )

    # given
    @installer.stubs( :build ).returns( 'SUCCESS' )

    # expects
    @listener.expects( :sleeping )

    # when
    @installer.build_if_necessary

    # then
    verify_mocks
  end
end


describe 'All Installers', :shared => true do
  include FileSandbox


  before( :each ) do
    Lucie::Log.stubs( :event )

    @svn = Object.new
    @installer = Installer.new( 'DUMMY_INSTALLER' )
    @installer.source_control = @svn
  end


  def stub_build label
    build = Object.new
    build.stubs( :label ).returns( label )
    build.stubs( :artifacts_directory ).returns( "installer1/build_#{ label }" )
    build.stubs( :run )
    build
  end


  def new_revision number
    Revision.new number, 'alex', DateTime.new( 2005, 1, 1 ), 'message', []
  end


  def new_mock_build label
    build = Object.new
    Build.expects( :new ).with( @installer, label ).returns( build )
    build.stubs( :artifacts_directory ).returns( "installer1/build-#{ label }" )
    build.stubs( :last ).returns( nil )
    build.stubs( :label ).returns( label )
    build
  end
end


describe Installer, 'when handling previous builds' do
  it_should_behave_like 'All Installers'


  it 'should hold all builds' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root
      sandbox.new :file => 'build-1/build_status.success'
      sandbox.new :file => 'build-10/build_status.success'
      sandbox.new :file => 'build-3/build_status.failure'
      sandbox.new :file => 'build-5/build_status.success'
      sandbox.new :file => 'build-5.2/build_status.success'
      sandbox.new :file => 'build-5.12/build_status.success'

      builds = @installer.builds.collect do | each |
        "#{ each.label } - #{ each.status }"
      end

      builds.join( ', ' ).should == '1 - success, 3 - failure, 5 - success, 5.2 - success, 5.12 - success, 10 - success'
      @installer.last_build.label.should == '10'
    end
  end


  it 'should not get builds when no installer path ' do
    @installer.expects( :path ).returns( nil )

    lambda do
      @installer.builds
    end.should raise_error( RuntimeError )
  end


  it 'should not have last complete build if never built' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root

      @installer.last_complete_build.should be_nil
    end
  end


  it 'should know last completed build' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root
      sandbox.new :file => 'build-1/build_status.success'
      sandbox.new :file => 'build-2/build_status.failure'
      sandbox.new :file => 'build-3/build_status.incomplete'

      @installer.last_complete_build.label.should == '2'
    end
  end


  it 'should have empty builds when never built' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root

      @installer.builds.should be_empty
    end
  end


  it 'should have last five builds' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root
      sandbox.new :file => 'build-1/build_status.success'
      sandbox.new :file => 'build-10/build_status.success'
      sandbox.new :file => 'build-3/build_status.failure'
      sandbox.new :file => 'build-5/build_status.success'
      sandbox.new :file => 'build-5.2/build_status.success'
      sandbox.new :file => 'build-5.12/build_status.success'

      builds = @installer.last_five_builds.collect do | each |
        "#{ each.label } - #{ each.status }"
      end

      builds.join( ', ' ).should == '10 - success, 5.12 - success, 5.2 - success, 5 - success, 3 - failure'
    end
  end


  it 'should get previous build' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root
      sandbox.new :file => 'build-1/build_status.success'
      sandbox.new :file => 'build-2/build_status.failure'
      sandbox.new :file => 'build-3/build_status.incomplete'

      build = @installer.find_build( '2' )
      @installer.previous_build( build ).label.should == '1'

      build = @installer.find_build( '1' )
      @installer.previous_build( build ).should be_nil
    end
  end


  it 'should get next build' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root
      sandbox.new :file => 'build-1/build_status.success'
      sandbox.new :file => 'build-2/build_status.failure'
      sandbox.new :file => 'build-3/build_status.incomplete'

      build = @installer.find_build( '1' )
      @installer.next_build( build ).label.should == '2'

      build = @installer.find_build( '2' )
      @installer.next_build( build ).label.should == '3'

      build = @installer.find_build( '3' )
      @installer.next_build( build ).should be_nil
    end
  end


  it 'should get last n builds' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root
      sandbox.new :file => 'build-1/build_status.success'
      sandbox.new :file => 'build-2/build_status.failure'
      sandbox.new :file => 'build-3/build_status.incomplete'

      @installer.last_builds( 2 ).length.should == 2
      @installer.last_builds( 5 ).length.should == 3
    end
  end
end


describe Installer, 'when loading configuration' do
  it_should_behave_like 'All Installers'


  it 'should load configuration from work directory and then root directory' do
    in_sandbox do | sandbox |
      Lucie::Log.stubs :event

      @installer.path = sandbox.root
      begin
        sandbox.new :file => 'work/lucie_config.rb', :with_contents => '$foobar=42; $barfoo = 12345'
        sandbox.new :file => 'lucie_config.rb', :with_contents => '$barfoo = 54321'

        @installer.load_config

        $foobar.should == 42
        $barfoo.should == 54321
      ensure
        $foobar = $barfoo = nil
      end
    end
  end


  it 'should mark config invalid if config contains invalid ruby code' do
    in_sandbox do | sandbox |
      invalid_ruby_code = 'class Invalid'
      @installer.path = sandbox.root
      sandbox.new :file => 'work/lucie_config.rb', :with_contents => invalid_ruby_code

      @installer.load_config

      @installer.settings.should be_empty
      @installer.config_file_content.strip.should == invalid_ruby_code
      @installer.should_not be_config_valid
      @installer.error_message.should match( /Could not load installer configuration:/ )
    end
  end


  it 'should retries after svn update if config is invalid' do
    Lucie::Log.stubs :event
    @installer.stubs( :load_and_remember ).raises
    @svn.expects( :update )

    @installer.load_config
  end


  it 'should remember settings' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root
      sandbox.new :file => 'work/lucie_config.rb', :with_contents => 'good = 4'
      sandbox.new :file => 'lucie_config.rb', :with_contents => 'time = 5'

      @installer.load_config

      @installer.settings.should == "good = 4\ntime = 5\n"
      @installer.should be_config_valid
      @installer.error_message.should be_empty
    end
  end


  it 'should detect configuration update' do
    @installer.config_tracker.expects( :config_modified? ).returns( true )
    @installer.should be_config_modified

    @installer.config_tracker.expects( :config_modified? ).returns( false )
    @installer.should_not be_config_modified
  end
end


describe Installer, 'when generating events' do
  it_should_behave_like 'All Installers'


  it 'should generate events' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root

      revision = new_revision( 5 )
      build = new_mock_build( '5' )
      build.stubs( :artifacts_directory ).returns( sandbox.root )

      @installer.stubs( :builds ).returns( [] )
      @installer.stubs( :config_modified? ).returns( false )
      @svn.expects( :latest_revision ).returns( revision )
      @svn.expects( :update ).with( @installer, revision )

      build.expects :run

      # event expectations
      listener = Object.new

      listener.expects( :polling_source_control )
      listener.expects( :new_revisions_detected ).with( [ revision ] )
      listener.expects( :build_started ).with( build )
      listener.expects( :build_finished ).with( build )
      listener.expects( :sleeping )

      @installer.add_plugin listener

      @installer.build_if_necessary
    end
  end
end


describe Installer, 'when checking last complete build status' do
  it_should_behave_like 'All Installers'



  it "should have 'success' status if last build succeeded" do
    BuilderStatus.stubs( :new ).returns( ok_builder_status )
    @installer.stubs( :builds ).returns( [ successful_build ] )

    @installer.last_complete_build_status.should == 'success'
  end


  it "should have 'failed' status if last build failed" do
    BuilderStatus.stubs( :new ).returns( ok_builder_status )
    @installer.stubs( :builds ).returns( [ failed_build ] )

    @installer.last_complete_build_status.should == 'failed'
  end


  it "should have 'never_built' status if never built" do
    BuilderStatus.stubs( :new ).returns( ok_builder_status )
    @installer.stubs( :last_complete_build ).returns( nil )

    @installer.last_complete_build_status.should == 'never_built'
  end


  it "should have 'failed' status if builder status is fatal" do
    BuilderStatus.stubs( :new ).returns( fatal_builder_status )

    @installer.last_complete_build_status.should == 'failed'
  end


  def fatal_builder_status
    builder_status = Object.new
    builder_status.stubs( :fatal? ).returns( true )
    builder_status
  end


  def ok_builder_status
    builder_status = Object.new
    builder_status.stubs( :fatal? ).returns( false )
    builder_status
  end


  def successful_build
    build = Object.new
    build.stubs( :incomplete? ).returns( false )
    build.stubs( :status ).returns( 'success' )
    build
  end


  def failed_build
    build = Object.new
    build.stubs( :incomplete? ).returns( false )
    build.stubs( :status ).returns( 'failed' )
    build
  end
end


describe Installer, 'when installing' do
  it_should_behave_like 'All Installers'


  it 'should run successful install' do
    Installer.stubs( :new ).returns( @installer )
    @installer.stubs( :last_build ).returns( completed_build_status )
    @installer.stubs( :last_complete_build_status ).returns( 'success' )

    install = Object.new
    Install.stubs( :new ).returns( install )
    install.expects( :run )

    Installer.install( dummy_node ).should == install
  end


  it 'should abort if build incomplete' do
    Installer.stubs( :new ).returns( @installer )
    @installer.stubs( :last_build ).returns( incomplete_build_status )
    @installer.stubs( :last_complete_build_status ).returns( 'failed' )

    lambda do
      Installer.install dummy_node
    end.should raise_error( RuntimeError, "Installer `DUMMY_INSTALLER' is incomplete." )
  end


  it 'should abort if last build failed' do
    Installer.stubs( :new ).returns( @installer )
    @installer.stubs( :last_build ).returns( completed_build_status )
    @installer.stubs( :last_complete_build_status ).returns( 'failed' )

    lambda do
      Installer.install dummy_node
    end.should raise_error( RuntimeError, "Installer `DUMMY_INSTALLER' is broken." )
  end


  def incomplete_build_status
    build = Object.new
    build.stubs( :incomplete? ).returns( true )
    build
  end


  def completed_build_status
    build = Object.new
    build.stubs( :incomplete? ).returns( false )
    build
  end


  def dummy_node
    node = Object.new
    node.stubs( :installer_name ).returns( 'DUMMY_INSTALLER' )
    node
  end
end


describe Installer do
  it_should_behave_like 'All Installers'


  it 'should have a default polling scheduler' do
    @installer.scheduler.should be_an_instance_of( PollingScheduler )
  end


  it 'should know builder state' do
    status = Object.new
    status.stubs( :status ).returns( 'STATUS' )
    BuilderStatus.stubs( :new ).returns( status )

    @installer.builder_state_and_activity.should == 'STATUS'
  end


  it 'should know builder error message' do
    error_message = Object.new
    error_message.stubs( :error_message ).returns( 'ERROR_MESSAGE' )
    BuilderStatus.stubs( :new ).returns( error_message )

    @installer.builder_error_message.should == 'ERROR_MESSAGE'
  end


  it 'should build with no logs' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root

      revision = new_revision( 5 )
      build = new_mock_build( '5' )

      build.stubs( :artifacts_directory ).returns( sandbox.root )

      @installer.stubs( :builds ).returns( [] )
      @installer.stubs( :config_modified? ).returns( false )
      @svn.expects( :latest_revision ).returns( revision )
      @svn.expects( :update ).with( @installer, revision )

      build.expects( :run )

      @installer.build_if_necessary
    end
  end


  it 'should generate events when build loop crashes' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root

      @installer.expects( :builds ).returns( [] )
      error = StandardError.new
      @svn.expects( :latest_revision ).raises( error )

      # event expectations
      listener = Object.new

      listener.expects( :polling_source_control )
      listener.expects( :build_loop_failed ).with( error )
      @installer.add_plugin listener

      lambda do
        @installer.build_if_necessary
      end.should raise_error( StandardError )
    end
  end


  it 'should generate events when build is broken' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root

      successful_build = stub_build( 1 )
      successful_build.stubs( :successful? ).returns( true )
      successful_build.stubs( :failed? ).returns( false )

      new_build = new_mock_build( '2' )
      new_build.stubs( :successful? ).returns( false )
      new_build.stubs( :failed? ).returns( true )
      new_build.expects( :run )

      @installer.expects( :last_build ).returns( successful_build )
      @installer.stubs( :builds ).returns( [ successful_build ] )
      @installer.stubs( :log_changeset )
      @svn.stubs( :update )

      # event expectations
      listener = Object.new

      listener.expects( :build_started )
      listener.expects( :build_finished )
      listener.expects( :build_broken )
      @installer.add_plugin listener

      @installer.build( [ new_revision( 2 ) ] )
    end
  end
end


describe Installer, 'when upgrading installer' do
  it_should_behave_like 'All Installers'


  it 'should success' do
    source_control = Object.new
    @installer.source_control = source_control

    source_control.expects( :update )
    @installer.expects( :request_build )

    lambda do
      @installer.upgrade
    end.should_not raise_error
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
