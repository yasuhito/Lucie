require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


class ConfigurationUpdator
  describe Client do
    context "updating client repository" do
      it "should update client repository" do
        node = mock( "node" )
        node.stub!( :ip_address ).and_return( "CLIENT_IP" )

        ssh = mock( "ssh" )
        SSH.stub!( :new ).and_return( ssh )
        ssh.should_receive( :sh_a ).with( "CLIENT_IP", /hg pull/ ).once.ordered
        ssh.should_receive( :sh_a ).with( "CLIENT_IP", /hg update/ ).once.ordered

        scm = mock( "scm" )
        Scm.stub!( :new ).and_return( scm )
        scm.stub!( :from ).and_return( Scm::Mercurial.new )

        Lucie::Server.stub!( :ip_address_for ).and_return( "SERVER_IP" )

        client = Client.new
        client.stub!( :repository_name_for ).with( node ).and_return( "REPOSITORY" )
        client.update node, "SERVER_REPOSITORY_DIRECTORY"
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
