require File.join( File.dirname( __FILE__ ), "..", "..", "spec_helper" )


module Command
  module ConfidentialDataServer
    describe App do
      context "when starting" do
        before :each do
          @password = "alpine"
          @encrypted_file = "confidential.enc"
        end


        it "should start if all mandatory options are passed" do
          cds = "Confidential Data Server"
          cds.should_receive( :start )
          ::ConfidentialDataServer.should_receive( :new ).with( @encrypted_file, @password, kind_of( Hash ) ).and_return( cds )
          App.new( [ "-e", @encrypted_file, "-P", @password ] ).main
        end


        it "should start with specified port number" do
          cds = "Confidential Data Server"
          cds.should_receive( :start ).with( 12345 )
          ::ConfidentialDataServer.should_receive( :new ).with( @encrypted_file, @password, kind_of( Hash ) ).and_return( cds )
          App.new( [ "-p", "12345", "-e", @encrypted_file, "-P", @password ] ).main
        end


        it "should abort if encypted file doesn't exist" do
          lambda do
            App.new( [ "-e", "NO_SUCH_FILE", "-P", @password ] ).main
          end.should raise_error( Errno::ENOENT, "No such file or directory - NO_SUCH_FILE" )
        end


        it "should abort if password option is missing" do
          lambda do
            App.new( [ "-e", "NO_SUCH_FILE" ] ).main
          end.should raise_error( RuntimeError, "password is missing" )
        end


        it "should abort if -e (--encrypted-file) option is missing" do
          lambda do
            App.new []
          end.should raise_error( RuntimeError, "--encrypted-file option is a mandatory." )
        end
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
