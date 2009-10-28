require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe ConfigurationUpdator do
  context "updating server repositories" do
    it "should update server repositories" do
      node_a = mock( "NODE_A", :name => "NODE_A" )
      node_b = mock( "NODE_B", :name => "NODE_B" )
      node_c = mock( "NODE_C", :name => "NODE_C" )

      client = mock( "client" )
      ConfigurationUpdator::Client.stub!( :new ).and_return( client )
      client.stub!( :repository_name_of ).with( node_a ).and_return( "REPOSITORY_A" )
      client.stub!( :repository_name_of ).with( node_b ).and_return( "REPOSITORY_B" )
      client.stub!( :repository_name_of ).with( node_c ).and_return( "REPOSITORY_C" )

      server = mock( "server" )
      ConfigurationUpdator::Server.stub!( :new ).and_return( server )
      server.stub!( :local_clone_directory ).with( instance_of( String ) ).and_return do | repos_name | "/tmp/lucie/#{ repos_name }" end
      server.should_receive( :update ).with( "REPOSITORY_A" ).once.ordered
      server.should_receive( :update ).with( "REPOSITORY_B" ).once.ordered
      server.should_receive( :update ).with( "REPOSITORY_C" ).once.ordered

      FileTest.stub!( :directory? ).with( "/tmp/lucie/REPOSITORY_A" ).and_return( true )
      FileTest.stub!( :directory? ).with( "/tmp/lucie/REPOSITORY_B" ).and_return( true )
      FileTest.stub!( :directory? ).with( "/tmp/lucie/REPOSITORY_C" ).and_return( true )

      ConfigurationUpdator.new.update_server_for [ node_a, node_b, node_c ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
