require File.dirname( __FILE__ ) + '/../spec_helper'


describe 'All Installers', :shared => true do
  include FileSandbox


  before( :each ) do
    @svn = Object.new
    @installer = Installer.new( 'LEMMINGS' )
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


  it 'should have last complete build status never_built when never built' do
    successful_builder_status = Object.new
    successful_builder_status.expects( :fatal? ).returns( false )
    BuilderStatus.expects( :new ).with( @installer ).returns( successful_builder_status )
    @installer.expects( :last_complete_build ).returns( nil )

    @installer.last_complete_build_status.should == 'never_built'
  end


  it 'should have last complete build status failed if builder status is fatal' do
    fatal_builder_status = Object.new
    fatal_builder_status.expects( :fatal? ).returns( true )
    BuilderStatus.expects( :new ).with( @installer ).returns( fatal_builder_status )

    @installer.last_complete_build_status.should == 'failed'
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
      Lucie::Log.stubs :event
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


  it 'should generate :no_new_revisions_detected event when no revisions' do
    in_sandbox do | sandbox |
      @installer.path = sandbox.root

      @installer.stubs( :new_revisions ).returns( [] )

      # event expectations
      listener = Object.new
      listener.expects( :no_new_revisions_detected )
      @installer.add_plugin listener

      @installer.build_if_necessary
    end
  end


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


  it 'should abort installation unless last build was successful' do
    node = Object.new
    node.stubs( :installer_name ).returns( 'DUMMY_INSTALLER' )

    failed_last_build = Object.new
    failed_last_build.stubs( :successful? ).returns( false )

    installer = Object.new
    installer.stubs( :last_build ).returns( failed_last_build )
    Installer.expects( :new ).with( 'DUMMY_INSTALLER' ).returns( installer )

    lambda do
      Installer.install node
    end.should raise_error( RuntimeError, "Installer `DUMMY_INSTALLER' is broken." )
  end


  it 'should run successful install' do
    node = Object.new
    node.stubs( :installer_name ).returns( 'DUMMY_INSTALLER' )

    success_last_build = Object.new
    success_last_build.stubs( :successful? ).returns( true )

    installer = Object.new
    installer.stubs( :last_build ).returns( success_last_build )
    Installer.expects( :new ).with( 'DUMMY_INSTALLER' ).returns( installer )

    install = Object.new
    Install.stubs( :new ).with( node, :new ).returns( install )
    install.expects( :run )

    Installer.install( node ).should == install
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
