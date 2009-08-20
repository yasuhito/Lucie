require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


class Configurator
  describe Client do
    context "guessing SCM" do
      before :each do
        @basedir = Client::REPOSITORY_BASE_DIRECTORY
        @ip = "192.168.0.1"

        @node = mock( "node" )
        @node.stub!( :name ).and_return( "NODE_NAME" )
        @node.stub!( :ip_address ).and_return( @ip )

        @ssh = mock( "ssh" )
        @ssh.should_receive( :sh ).with( @ip, "ls -1 #{ @basedir }" ).once.and_return( "REPOSITORY_NAME" )
        SSH.stub!( :new ).and_return( @ssh )
      end


      it "should determine that SCM is Mercurial" do
        @ssh.should_receive( :sh ).with( @ip, "ls -1 -d #{ @basedir }/REPOSITORY_NAME/.*" ).and_return( "#{ @basedir }/REPOSITORY_NAME/.hg" )
        Client.guess_scm( @node ).should == "Mercurial"
      end


      it "should determine that SCM is Git" do
        @ssh.should_receive( :sh ).with( @ip, "ls -1 -d #{ @basedir }/REPOSITORY_NAME/.*" ).and_return( "#{ @basedir }/REPOSITORY_NAME/.git" )
        Client.guess_scm( @node ).should == "Git"
      end


      it "should determine that SCM is Subversion" do
        @ssh.should_receive( :sh ).with( @ip, "ls -1 -d #{ @basedir }/REPOSITORY_NAME/.*" ).and_return( "#{ @basedir }/REPOSITORY_NAME/.svn" )
        Client.guess_scm( @node ).should == "Subversion"
      end


      it "should raise if failed to determine SCM" do
        @ssh.should_receive( :sh ).with( @ip, "ls -1 -d #{ @basedir }/REPOSITORY_NAME/.*" ).and_return( "#{ @basedir }/REPOSITORY_NAME/.unknown" )
        lambda do
          Client.guess_scm( @node )
        end.should raise_error( "Cannot determine SCM used on NODE_NAME:REPOSITORY_NAME" )
      end
    end


    context "initializing a client" do
      before :each do
        @ssh = mock( "ssh" ).as_null_object
        SSH.stub!( :new ).and_return( @ssh )
      end


      it "should create a configurator base directory if not found" do
        @ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "test -d /var/lib/lucie/config" ).and_raise( "test -d failed" )
        @ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "mkdir -p /var/lib/lucie/config" )
        Client.new.setup "DUMMY_IP_ADDRESS"
      end


      it "should not create a configurator base directory if found" do
        @ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "test -d /var/lib/lucie/config" )
        Client.new.setup "DUMMY_IP_ADDRESS"
      end
    end


    context "creating a configuration repository clone on a client" do
      it "should make a clone repository on the client" do
        ssh = mock( "ssh" ).as_null_object
        SSH.stub!( :new ).and_return( ssh )
        Configuration.stub!( :temporary_directory ).and_return( "/tmp/lucie" )

        ssh.should_receive( :sh_a ).with( "DUMMY_CLIENT_IP", /^scp/ )

        Client.new( :mercurial ).install "DUMMY_SERVER_IP", "DUMMY_CLIENT_IP", "ssh://myrepos.org//lucie"
      end
    end


    context "updating configuration repository" do
      it "should update configuration repository" do
        ssh = mock( "ssh" ).as_null_object
        SSH.stub!( :new ).and_return( ssh )

        ssh.stub!( :sh ).with( "DUMMY_IP_ADDRESS", "ls -1 /var/lib/lucie/config" ).and_return( "LDB_CHECKOUT_DIRECTORY" )
        ssh.should_receive( :sh_a ).with( "DUMMY_IP_ADDRESS", /hg pull/ )
        ssh.should_receive( :sh_a ).with( "DUMMY_IP_ADDRESS", /hg update/ )

        Client.new( :mercurial ).update "DUMMY_IP_ADDRESS"
      end
    end


    context "starting configuration process" do
      it "should execute configuration tool" do
        ssh = mock( "ssh" )
        SSH.stub!( :new ).and_return( ssh )

        ssh.stub!( :sh ).with( "DUMMY_IP_ADDRESS", "ls -1 /var/lib/lucie/config" ).and_return( "LDB_CHECKOUT_DIRECTORY" )
        ssh.should_receive( :sh_a ).with( "DUMMY_IP_ADDRESS", /make$/, an_instance_of( Lucie::Logger::Null ) )

        Client.new.start "DUMMY_IP_ADDRESS"
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
