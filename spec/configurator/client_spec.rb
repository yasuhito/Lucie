require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


module Configurator
  describe Client do
    context "initializing a client" do
      before :each do
        @ssh = mock( "ssh" )
        SSH.stub!( :new ).and_return( @ssh )
      end


      it "should create a configurator base directory if not found" do
        @ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "test -d /var/lib/lucie/config" ).and_raise( "test -d failed" )
        @ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "mkdir -p /var/lib/lucie/config" )
        Configurator::Client.new.setup "DUMMY_IP_ADDRESS"
      end


      it "should not create a configurator base directory if found" do
        @ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", "test -d /var/lib/lucie/config" )
        Configurator::Client.new.setup "DUMMY_IP_ADDRESS"
      end
    end


    context "creating a configuration repository clone on a client" do
      it "should make a clone repository on the client" do
        ssh = mock( "ssh" )
        SSH.stub!( :new ).and_return( ssh )
        Configuration.stub!( :temporary_directory ).and_return( "/tmp/lucie" )

        ssh.should_receive( :sh ).with( "DUMMY_CLIENT_IP", /^scp/ )

        Client.new( :mercurial ).install "DUMMY_SERVER_IP", "DUMMY_CLIENT_IP", "ssh://myrepos.org//lucie"
      end
    end


    context "when starting configuration process" do
      it "should execute configuration tool" do
        ssh = mock( "ssh" )
        SSH.stub!( :new ).and_return( ssh )

        ssh.stub!( :sh ).with( "DUMMY_IP_ADDRESS", "ls -1 /var/lib/ldb" ).and_return( "LDB_CHECKOUT_DIRECTORY" )
        ssh.should_receive( :sh ).with( "DUMMY_IP_ADDRESS", /make$/ )

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
