require File.dirname( __FILE__ ) + '/../spec_helper'


#
# Verbose ON/OFF test.
#
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
    BuilderStarter.expects( :exec ).with( "#{ RAILS_ROOT }/installer build INSTALLER_NAME " ).returns( 'PID' )

    # when
    BuilderStarter.begin_builder 'INSTALLER_NAME'

    # then
    verify_mocks
  end


  it "should exec 'installer build <installer name> --trace' if verbose mode is on" do
    # given
    $VERBOSE_MODE = true

    # expects
    BuilderStarter.expects( :exec ).with( "#{ RAILS_ROOT }/installer build INSTALLER_NAME --trace" ).returns( 'PID' )

    # when
    BuilderStarter.begin_builder 'INSTALLER_NAME'

    # then
    verify_mocks
  end
end


#
# Test if PID file created.
#
describe BuilderStarter, 'when creating PID file' do
  it "should create installer pid file in the directory '[lucie]/tmp/pids/builders/<installer name>.pid' if successfully spawns a builder subprocess" do
    file = mock( 'FILE' )

    # given
    BuilderStarter.stubs( :fork ).returns( 'DUMMY_PID' )

    # expects
    FileUtils.expects( :mkdir_p ).with( "#{ RAILS_ROOT }/tmp/pids/builders" )
    File.expects( :open ).with( "#{ RAILS_ROOT }/tmp/pids/builders/INSTALLER_NAME.pid", 'w' ).yields( file )
    file.expects( :write ).with( 'DUMMY_PID' )

    # when
    BuilderStarter.begin_builder 'INSTALLER_NAME'

    # then
    verify_mocks
  end
end


#
# Tests for run_builders_at_startup flag
#
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


  it "should not run builders if 'run_builders_at_startup' option is ON but no installer is added" do
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


  it "should not run builders if 'run_builders_at_startup' option is OFF" do
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
    installer = Object.new
    installer.stubs( :name ).returns( name )
    installer
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
