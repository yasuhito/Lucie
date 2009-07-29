require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe Configurator do
  it "should be initialized with scm implementation specified" do
    configurator = Configurator.new( :mercurial )
    configurator.scm.should == :mercurial
  end


  it "should have a configuration option for dpkg command" do
    configurator = Configurator.new
    configurator.dpkg = Dpkg.new
  end


  context "checking scm" do
    context "not using scm" do
      it "should do nothing" do
        lambda do
          Configurator.new.scm_installed?
        end.should_not raise_error
      end
    end


    context "mercurial is installed" do
      before :each do
        dpkg = mock( "dpkg" )
        dpkg.should_receive( :installed? ).and_return( true )
        Dpkg.stub!( :new ).and_return( dpkg )
      end


      it "should send a OK message" do
        messenger = mock( "messenger" )
        messenger.should_receive( :print ).with( "Checking mercurial ... " )
        messenger.should_receive( :puts ).with( "INSTALLED" )
        configurator = Configurator.new( :mercurial, messenger )
        configurator.scm_installed?
      end
    end


    context "mercurial is not installed" do
      before :each do
        dpkg = mock( "dpkg" )
        dpkg.should_receive( :installed? ).and_return( false )
        Dpkg.stub!( :new ).and_return( dpkg )
      end


      it "should send an error message and raise" do
        messenger = mock( "messenger" )
        messenger.should_receive( :print ).with( "Checking mercurial ... " )
        messenger.should_receive( :puts ).with( "NOT INSTALLED" )
        configurator = Configurator.new( :mercurial, messenger )

        lambda do
          configurator.scm_installed?
        end.should raise_error( "mercurial is not installed" )
      end
    end
  end
end
