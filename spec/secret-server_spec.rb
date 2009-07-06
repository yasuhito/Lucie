require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe SecretServer do
  before :each do
    encrypted = Tempfile.new( "secret-server" )
    raw = Tempfile.new( "secret-server" )
    raw.print "decrypted"
    raw.flush
    system "openssl enc -pass pass:password -e -aes256 < #{ raw.path } > #{ encrypted.path }"
    encrypted.flush
    @secret_server = SecretServer.new( encrypted.path, "password" )
  end


  context "when starting secret server" do
    it "should listen to port 58243" do
      TCPServer.should_receive( :open ).with( 58243 ).and_return( "SERVER" )
      Kernel.should_receive( :loop )
      @secret_server.start
    end
  end


  context "when a connection created by a client" do
    before :each do
      @server = mock( "server" )
      TCPServer.should_receive( :open ).with( 58243 ).and_return( @server )
      Kernel.should_receive( :loop ).and_yield
    end


    it "should return decrypted string" do
      client = mock( "client" )
      client.should_receive( :print ).with( "decrypted" )
      client.should_receive( :close )
      @server.should_receive( :accept ).and_return( client )
      Thread.should_receive( :start ).with( client ).and_yield( client )
      @secret_server.start
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
