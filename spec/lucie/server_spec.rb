require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


module Lucie
  describe Server do
    context "when getting Lucie server's IP address" do
      before :each do
        @node = mock( "node" )
        @node.stub!( :net_info ).and_return( [ "157.82.22.0", "255.255.254.0" ] )

        @interface = mock( "interface" )
      end


      it "should return Lucie server's IP address if found" do
        @interface.stub!( :subnet ).and_return( "157.82.0.0" )
        @interface.stub!( :ip_address ).and_return( "157.82.22.4" )
        Server.ip_address_for( @node, :interfaces => [ @interface ] ).should == "157.82.22.4"
      end


      it "should raise if no appropriate NIC found" do
        @interface.stub!( :subnet ).and_return( "157.83.0.0" )
        @interface.stub!( :ip_address ).and_return( "157.83.22.4" )
        lambda do
          Server.ip_address_for @node, :interfaces => [ @interface ]
        end.should raise_error( "No suitable network interface for installation found" )
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
