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
        configurator = Configurator.new( @scm, :messenger => messenger )
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
        configurator = Configurator.new( @scm, :messenger => messenger )
        configurator.scm_installed?
      end.should raise_error( "#{ @scm } is not installed" )
    end
  end


  context "making a clone of configuration repository on Lucie server" do
    before :each do
      @temporary_directory = "/tmp/lucie"
      Configuration.stub!( :temporary_directory ).and_return( @temporary_directory )
      @url = "ssh://myrepos.org/lucie"
    end


    it "should create a clone directory on the Lucie server" do
      hg = mock( "hg" )
      Scm::Hg.stub!( :new ).and_return( hg )

      target = File.join( @temporary_directory, "ldb", @url.gsub( /[\/:@]/, "_" ) )
      hg.should_receive( :clone ).with( @url, target )

      configurator = Configurator.new( @scm )
      configurator.clone @url
    end
  end


  context "initializing a client" do
    before :each do
      @ssh = mock( "ssh" )
      SSH.stub!( :new ).and_return( @ssh )
    end


    it "should create a configurator base directory if not found" do
      @ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "test -d /var/lib/lucie/config" ).and_return( false )
      @ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "mkdir -p /var/lib/lucie/config" )

      configurator = Configurator.new( @scm )
      configurator.setup "DUMMY_IP_ADDRESS"
    end


    it "should not create a configurator base directory if found" do
      @ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "test -d /var/lib/lucie/config" ).and_return( true )

      configurator = Configurator.new( @scm )
      configurator.setup "DUMMY_IP_ADDRESS"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
