require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe ConfigurationUpdator do
  context "updating server repositories" do
    it "should update server repositories" do
      node_a = mock( "node_a" )
      node_b = mock( "node_b" )
      node_c = mock( "node_c" )
      node_a.stub!( :ip_address ).and_return( "IP_ADDRESS_A" )
      node_b.stub!( :ip_address ).and_return( "IP_ADDRESS_B" )
      node_c.stub!( :ip_address ).and_return( "IP_ADDRESS_C" )

      client = mock( "client" )
      ConfigurationUpdator::Client.stub!( :new ).and_return( client )
      client.stub!( :repository_name_for ).with( "IP_ADDRESS_A" ).and_return( "REPOSITORY_A" )
      client.stub!( :repository_name_for ).with( "IP_ADDRESS_B" ).and_return( "REPOSITORY_B" )
      client.stub!( :repository_name_for ).with( "IP_ADDRESS_C" ).and_return( "REPOSITORY_C" )

      server = mock( "server" )
      ConfigurationUpdator::Server.stub!( :new ).and_return( server )
      server.should_receive( :update ).with( "REPOSITORY_A" ).once.ordered
      server.should_receive( :update ).with( "REPOSITORY_B" ).once.ordered
      server.should_receive( :update ).with( "REPOSITORY_C" ).once.ordered

      updator = ConfigurationUpdator.new( :verbose => true )
      updator.update_server_for [ node_a, node_b, node_c ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
