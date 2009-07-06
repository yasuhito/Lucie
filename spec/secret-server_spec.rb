require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe SecretServer do
  before :each do
    @encrypted = Tempfile.new( "secret-server" )
    raw = Tempfile.new( "secret-server" )
    raw.print "decrypted"
    raw.flush
    system "openssl enc -pass pass:password -e -aes256 < #{ raw.path } > #{ @encrypted.path }"
    @encrypted.flush
  end


  context "when starting secret server" do
    it "should listen to port 58243 on localhost" do
      TCPServer.should_receive( :open ).with( "localhost", 58243 ).and_return( "SERVER" )
      Kernel.should_receive( :loop )
      SecretServer.new( @encrypted.path, "password" ).start
    end


    it "should raise if decryption password was incorrect" do
      lambda do
        SecretServer.new( @encrypted.path, "incorrect password" )
      end.should raise_error( RuntimeError, "Failed to decrypt #{ @encrypted.path }." )
    end


    it "should raise if encrypted file not found" do
      lambda do
        SecretServer.new( "NO_SUCH_FILE", "password" )
      end.should raise_error( Errno::ENOENT, "No such file or directory - NO_SUCH_FILE" )
    end
  end


  context "when connected from a client" do
    before :each do
      @server = mock( "server" )
      TCPServer.should_receive( :open ).with( "localhost", 58243 ).and_return( @server )
      Kernel.should_receive( :loop ).and_yield
    end


    it "should return decrypted string" do
      client = mock( "client" )
      client.should_receive( :print ).with( "decrypted" )
      client.should_receive( :close )
      @server.should_receive( :accept ).and_return( client )
      Thread.should_receive( :start ).with( client ).and_yield( client )
      SecretServer.new( @encrypted.path, "password" ).start
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
