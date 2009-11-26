require File.join( File.dirname( __FILE__ ), "spec_helper" )


describe ConfidentialDataServer do
  before :each do
    @encrypted = Tempfile.new( "confidential-data-server" )
    system "openssl enc -pass pass:#{ password } -e -aes256 < #{ raw_confidential_file.path } > #{ @encrypted.path }"
  end


  context "when starting" do
    it "should listen to port 58243 on localhost" do
      Kernel.stub!( :loop )
      TCPServer.should_receive( :open ).with( "localhost", 58243 ).and_return( "SERVER" )
      ConfidentialDataServer.new( @encrypted.path, password ).start
    end


    it "should raise if decryption password was incorrect" do
      lambda do
        ConfidentialDataServer.new( @encrypted.path, "incorrect password" )
      end.should raise_error( RuntimeError, "Failed to decrypt #{ @encrypted.path }." )
    end


    it "should raise if encrypted file not found" do
      lambda do
        ConfidentialDataServer.new( "NO_SUCH_FILE", password )
      end.should raise_error( Errno::ENOENT, "No such file or directory - NO_SUCH_FILE" )
    end
  end


  def raw_confidential_file
    raw = Tempfile.new( "confidential-data-server" )
    raw.print "decrypted"
    raw.flush
    raw
  end


  context "when connected from a client" do
    before :each do
      @server = mock( "server" )
      TCPServer.stub!( :open ).with( "localhost", 58243 ).and_return( @server )
      Kernel.stub!( :loop ).and_yield
    end


    it "should return decrypted string" do
      client = mock( "client" )
      Thread.stub!( :start ).with( client ).and_yield( client )

      @server.should_receive( :accept ).and_return( client )
      client.should_receive( :print ).with( "decrypted" )
      client.should_receive( :close )

      ConfidentialDataServer.new( @encrypted.path, password ).start
    end
  end


  def password
    "TEST_PASSWORD"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
