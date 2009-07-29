require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe Configurator do
  before :each do
    @scm = :mercurial
  end


  it "should be initialized with backend scm specified" do
    configurator = Configurator.new( @scm )
    configurator.scm.should == @scm
  end


  it "should have a configuration option to specify dpkg command" do
    configurator = Configurator.new
    configurator.dpkg = Dpkg.new
  end


  context "checking if backend SCM is installed" do
    it "should do nothing if not using SCM" do
      lambda do
        Configurator.new.scm_installed?
      end.should_not raise_error
    end


    it "should send a OK message if the SCM is installed" do
      dpkg = mock( "dpkg" )
      dpkg.should_receive( :installed? ).and_return( true )
      Dpkg.stub!( :new ).and_return( dpkg )

      messenger = mock( "messenger" )
      messenger.should_receive( :puts ).with( "Checking #{ @scm } ... INSTALLED" )

      lambda do
        configurator = Configurator.new( @scm, messenger )
        configurator.scm_installed?
      end.should_not raise_error
    end


    it "should send an error message and raise if the SCM is not installed" do
      dpkg = mock( "dpkg" )
      dpkg.should_receive( :installed? ).and_return( false )
      Dpkg.stub!( :new ).and_return( dpkg )

      messenger = mock( "messenger" )
      messenger.should_receive( :puts ).with( "Checking #{ @scm } ... NOT INSTALLED" )
      
      lambda do
        configurator = Configurator.new( @scm, messenger )
        configurator.scm_installed?
      end.should raise_error( "#{ @scm } is not installed" )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
