require File.dirname( __FILE__ ) + '/../spec_helper'


# As a Lucie script running in the production environment,
# I want 'installer build' subprocess to be spawned automatically
# So that installers are successfully built.

describe BuilderStarter, 'when spawning builder subprocess' do
  before( :each ) do
    BuilderStarter.stubs( :fork ).returns( false )
    FileUtils.stubs( :mkdir_p )
    File.stubs( :open )
  end


  after( :each ) do
    $VERBOSE_MODE = false
  end


  it "should exec 'installer build <installer name>' if verbose mode if off" do
    # given
    $VERBOSE_MODE = false

    # expects
    BuilderStarter.expects( :exec ).with( "#{ RAILS_ROOT }/installer build INSTALLER_ONE " ).returns( 'PID' )

    # when
    BuilderStarter.begin_builder 'INSTALLER_ONE'

    # then
    verify_mocks
  end


  it "should exec 'installer build <installer name> --trace' if verbose mode is on" do
    # given
    $VERBOSE_MODE = true

    # expects
    BuilderStarter.expects( :exec ).with( "#{ RAILS_ROOT }/installer build INSTALLER_ONE --trace" ).returns( 'PID' )

    # when
    BuilderStarter.begin_builder 'INSTALLER_ONE'

    # then
    verify_mocks
  end
end


# As a Lucie script running in the production environment,
# I want pid files for each installers to be created automatically
# So that multiple builders for one installer should not run at the same time.

describe BuilderStarter, 'when creating PID file' do
  it "should create installer pid file in the directory '[lucie]/tmp/pids/builders/<installer name>.pid' if successfully spawns a builder subprocess" do
    file = mock( 'FILE' )

    # given
    BuilderStarter.stubs( :fork ).returns( 'DUMMY_PID' )

    # expects
    FileUtils.expects( :mkdir_p ).with( "#{ RAILS_ROOT }/tmp/pids/builders" )
    file.expects( :write ).with( 'DUMMY_PID' )
    File.expects( :open ).with( "#{ RAILS_ROOT }/tmp/pids/builders/INSTALLER_ONE.pid", 'w' ).yields( file )

    # when
    BuilderStarter.begin_builder 'INSTALLER_ONE'

    # then
    verify_mocks
  end
end


# As a Lucie script running in the production environment,
# I want to control builder starter by 'run_builders_at_startup' option and installer state
# So that unnecessary builders does not start building installers.

describe BuilderStarter, 'when calling start_builders' do
  it "should begin builders for each installers if 'run_builders_at_startup' option is on and two installers are added" do
    # given
    BuilderStarter.run_builders_at_startup = true
    Installers.stubs( :load_all ).returns( [ installer_stub( 'INSTALLER_ONE' ), installer_stub( 'INSTALLER_TWO' ) ] )

    # expects
    BuilderStarter.expects( :begin_builder ).with( 'INSTALLER_ONE' )
    BuilderStarter.expects( :begin_builder ).with( 'INSTALLER_TWO' )

    # when
    BuilderStarter.start_builders

    # then
    verify_mocks
  end


  it "should not run builders if 'run_builders_at_startup' option is on but no installer is added" do
    # given
    BuilderStarter.run_builders_at_startup = true
    Installers.stubs( :load_all ).returns( [ ] )

    # expects
    BuilderStarter.expects( :begin_builder ).never

    # when
    BuilderStarter.start_builders

    # then
    verify_mocks
  end


  it "should not run builders if 'run_builders_at_startup' option is off" do
    # given
    BuilderStarter.run_builders_at_startup = false

    # expects
    Installers.expects( :load_all ).never

    # when
    BuilderStarter.start_builders

    # then
    verify_mocks
  end


  def installer_stub name
    Installer.new( name, Object.new )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
