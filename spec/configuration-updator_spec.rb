require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe ConfigurationUpdator do
  context "updating server repositories" do
    it "should update server repositories" do
      client = mock( "client" )
      ConfigurationUpdator::Client.stub!( :new ).and_return( client )
      client.stub!( :repository_name_for ).with( "NODE_A" ).and_return( "REPOSITORY_A" )
      client.stub!( :repository_name_for ).with( "NODE_B" ).and_return( "REPOSITORY_B" )
      client.stub!( :repository_name_for ).with( "NODE_C" ).and_return( "REPOSITORY_C" )

      server = mock( "server" )
      ConfigurationUpdator::Server.stub!( :new ).and_return( server )
      server.should_receive( :update ).with( "REPOSITORY_A" ).once.ordered
      server.should_receive( :update ).with( "REPOSITORY_B" ).once.ordered
      server.should_receive( :update ).with( "REPOSITORY_C" ).once.ordered

      ConfigurationUpdator.new.update_server_for [ "NODE_A", "NODE_B", "NODE_C" ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
