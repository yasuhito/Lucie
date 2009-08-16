require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


class Configurator
  describe Server do
    before :each do
      Configuration.stub!( :temporary_directory ).and_return( "/tmp/lucie" )
    end


    context "initializing a client" do
      it "should create a temporary directory to checkout configuration repository if not found" do
        FileTest.stub!( :exists? ).with( "/tmp/lucie/config" ).and_return( false )
        Lucie::Utils.should_receive( :mkdir_p ).with( "/tmp/lucie/config", an_instance_of( Hash ), nil )
        Server.new.setup
      end


      it "should not create a temporary directory to checkout configuration repository if found" do
        FileTest.stub!( :exists? ).with( "/tmp/lucie/config" ).and_return( true )
        Lucie::Utils.should_not_receive( :mkdir_p ).with( "/tmp/lucie/config" )
        Server.new.setup
      end
    end


    context "checking if backend SCM is installed" do
      before :each do
        @dpkg = mock( "dpkg" )
        Dpkg.stub!( :new ).and_return( @dpkg )
      end


      it "should not raise if the SCM is installed" do
        @dpkg.stub!( :installed? ).with( "mercurial" ).and_return( true )
        lambda do
          Server.new( :mercurial ).check_backend_scm
        end.should_not raise_error
      end


      it "should raise if the SCM is not installed" do
        @dpkg.stub!( :installed? ).with( "mercurial" ).and_return( false )
        lambda do
          Server.new( :mercurial ).check_backend_scm
        end.should raise_error( "Mercurial is not installed" )
      end


      it "should do nothing if not using SCM" do
        lambda do
          Server.new.check_backend_scm
        end.should_not raise_error
      end
    end


    context "making a clone of configuration repository on Lucie server" do
      before :each do
        @url = "ssh://myrepos.org//lucie"
      end


      it "should create a clone directory on the Lucie server" do
        mercurial = mock( "mercurial" )
        Scm::Mercurial.stub!( :new ).and_return( mercurial )

        target = File.join( Configuration.temporary_directory, "config", Configurator.convert( @url ) )
        mercurial.should_receive( :clone ).with( @url, target )
        
        Server.new( :mercurial ).clone @url
      end


      it "should raise if scm not specified" do
        lambda do
          Server.new.clone @url
        end.should raise_error( "scm is not specified" )
      end
    end


    context "making a local clone of configuration repository" do
      it "should create a local clone directory on the Lucie server" do
        mercurial = mock( "mercurial" )
        Scm::Mercurial.stub!( :new ).and_return( mercurial )
        mercurial.should_receive( :clone ).with( "ssh://DUMMY_SERVER_IP//tmp/lucie/config/http___myrepos.org__lucie", "/tmp/lucie/config/http___myrepos.org__lucie.local" )
        Server.new( :mercurial ).clone_clone "http://myrepos.org//lucie", "DUMMY_SERVER_IP"
      end
    end


    context "updating configuration repository" do
      it "should update configuration repository" do
        mercurial = mock( "mercurial" )
        Scm::Mercurial.stub!( :new ).and_return( mercurial )
        mercurial.should_receive( :update ).with( "/tmp/lucie/config/http___myrepos.org__lucie" )
        mercurial.should_receive( :update ).with( "/tmp/lucie/config/http___myrepos.org__lucie.local" )
        Server.new( :mercurial ).update Configurator.convert( "http://myrepos.org//lucie" )
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
