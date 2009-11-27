require File.join( File.dirname( __FILE__ ), "..", "spec_helper" )


class Service
  describe Dhcp do
    context "when failed to determine domainname" do
      before :each do
        Facter.should_receive( :value ).with( "domain" ).and_return( nil )
      end


      it "should raise error" do
        node = Node.new( "DUMMY_NODE", :mac_address => "11:22:33:44:55:66", :ip_address => "192.168.0.100", :netmask_address => "255.255.255.0" )
        eth0 = mock( "eth0", :ip_address => "192.168.0.1", :netmask => "255.255.255.0", :subnet => Network.network_address( "192.168.0.1", "255.255.255.0" ) )
        dhcp_service = Dhcp.new( { :verbose => true, :dry_run => true, :messenger => StringIO.new( "" ) } )
        lambda do
          dhcp_service.setup [ node ], eth0
        end.should raise_error( RuntimeError, "Cannot resolve Lucie server's domain name." )
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:


