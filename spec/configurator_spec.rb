require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe Configurator do
  before :each do
    @node = mock( "node" )
  end


  context "guessing scm" do
    it "should determine scm" do
      Configurator::Client.should_receive( :guess_scm ).and_return( "Mercurial" )
      Configurator.guess_scm( @node ).should == "Mercurial"
    end
  end


  context "executing node update" do
    before :each do
      @client = mock( "client" )
      Configurator::Client.stub!( :new ).and_return( @client )
    end


    it "should update appropriate repositories on Lucie server" do
      server = mock( "server" )
      Configurator::Server.stub!( :new ).and_return( server )

      @client.stub!( :repository_name ).with( "192.168.0.1" ).and_return( "REPOSITORY_NAME" )
      @node.stub!( :ip_address ).and_return( "192.168.0.1" )

      server.should_receive( :update ).with( "REPOSITORY_NAME" )
      Configurator.new( "Mercurial" ).update_server_for [ @node ]
    end


    it "should raise if no appropriate repository found on Lucie server" do
      @client.stub!( :repository_name ).with( "192.168.0.1" ).and_raise( RuntimeError )
      @node.stub!( :name ).and_return( "NODE_NAME" )
      @node.stub!( :ip_address ).and_return( "192.168.0.1" )

      lambda do
        Configurator.new( "Mercurial" ).update_server_for [ @node ]
      end.should raise_error( "Configuration repository for NODE_NAME not found on Lucie server." )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
