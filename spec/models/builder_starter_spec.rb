require File.dirname( __FILE__ ) + '/../spec_helper'


describe BuilderStarter do
  include FileSandbox


  before( :each ) do
    $VERBOSE_MODE = false
    BuilderStarter.run_builders_at_startup = true

    @svn = Object.new
    @installer_one = Installer.new( 'ONE', @svn )
    @installer_two = Installer.new( 'TWO', @svn )
  end


  after( :each ) do
    $VERBOSE_MODE = false
    BuilderStarter.run_builders_at_startup = true
  end


  it 'should begin builder for each installer' do
    Installers.expects( :load_all ).returns( [ @installer_one, @installer_two ] )

    BuilderStarter.expects( :begin_builder ).with( @installer_one.name )
    BuilderStarter.expects( :begin_builder ).with( @installer_two.name )

    lambda do
      BuilderStarter.start_builders
    end.should_not raise_error
  end


  it 'should execute builder' do
    BuilderStarter.expects( :fork ).returns( false )
    BuilderStarter.expects( :exec ).with( "#{ RAILS_ROOT }/installer build ONE " ).returns( 'PID' )
    FileUtils.stubs( :mkdir_p )
    file = Object.new
    file.expects( :write ).with( 'PID' )
    File.expects( :open ).with( "#{ RAILS_ROOT }/tmp/pids/builders/ONE.pid", 'w' ).yields( file )

    lambda do
      BuilderStarter.begin_builder @installer_one.name
    end.should_not raise_error
  end


  it 'should invoke builder in verbose mode' do
    $VERBOSE_MODE = true
    BuilderStarter.expects( :fork ).returns( false )
    BuilderStarter.expects( :exec ).with( "#{ RAILS_ROOT }/installer build ONE --trace" ).returns( 'PID' )
    FileUtils.stubs( :mkdir_p )
    file = Object.new
    file.expects( :write ).with( 'PID' )
    File.expects( :open ).with( "#{ RAILS_ROOT }/tmp/pids/builders/ONE.pid", 'w' ).yields( file )

    lambda do
      BuilderStarter.begin_builder @installer_one.name
    end.should_not raise_error
  end


  it "should not run builders when 'run_builders_at_startup' is off" do
    lambda do
      BuilderStarter.run_builders_at_startup = false
      BuilderStarter.start_builders
    end.should_not raise_error
  end
end
