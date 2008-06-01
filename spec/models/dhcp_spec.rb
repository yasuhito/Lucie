#
# dhcp_spec.rb - Rspec for Dhcp model.
#


require File.dirname( __FILE__ ) + '/../spec_helper'


#
# Shared base group #1
#
describe 'Dhcp with dummy nodes', :shared => true do
  before( :each ) do
    @dhcp = Dhcp.new
    Dhcp.stubs( :new ).returns( @dhcp )

    Nodes.stubs( :load_all ).returns( [ dummy_node1, dummy_node2 ] )

    File.stubs( :copy ).with( '/etc/dhcp3/dhcpd.conf', '/etc/dhcp3/dhcpd.conf.orig' )
    File.stubs( :open ).with( '/etc/dhcp3/dhcpd.conf', 'w' ).yields( StringIO.new( '' ) )

    Facter.stubs( :value ).with( 'domain' ).returns( 'DUMMY_DOMAIN' )
    Facter.stubs( :value ).with( 'ipaddress' ).returns( 'DUMMY_IP_ADDRESS' )
  end


  def dummy_node1
    node = Object.new
    node.stubs( :enable? ).returns( true )
    node.stubs( :gateway_address).returns( '192.168.1.254' )
    node.stubs( :ip_address ).returns( '192.168.1.10' )
    node.stubs( :mac_address ).returns( 'MAC_ADDRESS' )
    node.stubs( :name ).returns( 'DUMMY_NODE' )
    node.stubs( :netmask_address ).returns( '255.255.255.0' )
    node
  end


  def dummy_node2
    node = Object.new
    node.stubs( :enable? ).returns( true )
    node.stubs( :gateway_address).returns( '192.168.1.254' )
    node.stubs( :ip_address ).returns( '192.168.1.11' )
    node.stubs( :mac_address ).returns( 'MAC_ADDRESS' )
    node.stubs( :name ).returns( 'DUMMY_NODE2' )
    node.stubs( :netmask_address ).returns( '255.255.255.0' )
    node
  end
end


#
# Shared base group #2
#
describe 'dhcp with dummy nodes, dhcpd installed', :shared => true do
  it_should_behave_like 'Dhcp with dummy nodes'


  before( :each ) do
    File.stubs( :exists? ).with( '/usr/sbin/dhcpd3' ).returns( true )
  end
end


################################################################################
# Succeed to setup dhcpd
################################################################################


describe Dhcp, 'when everything is properly configured' do
  it_should_behave_like 'dhcp with dummy nodes, dhcpd installed'


  it 'should setup DHCP' do
    @dhcp.stubs( :sh_exec ).with( '/etc/init.d/dhcp3-server restart' ).returns( 'SUCCESS' )

    lambda do
      Dhcp.setup
    end.should_not raise_error
  end
end


################################################################################
# Fail to setup dhcpd
################################################################################


describe Dhcp, 'when no node is added yet' do
  it 'should return silently when Dhcp.setup called' do
    @dhcp.stubs( :all_subnets ).returns( { } )

    lambda do
      Dhcp.setup
    end.should_not raise_error
  end
end


describe Dhcp, 'when dhcpd is not installed' do
  it_should_behave_like 'Dhcp with dummy nodes'


  it 'should raise when Dhcp.setup called' do
    File.stubs( :exists? ).with( '/usr/sbin/dhcpd3' ).returns( false )

    lambda do
      Dhcp.setup
    end.should raise_error( 'dhcp3-server package is not installed. Please install first.' )
  end
end


describe Dhcp, 'when dhcpd fails to restart' do
  it_should_behave_like 'dhcp with dummy nodes, dhcpd installed'


  it 'should raise when Dhcp.setup called' do
    @dhcp.stubs( :sh_exec ).with( '/etc/init.d/dhcp3-server restart' ).raises( RuntimeError )

    lambda do
      Dhcp.setup
    end.should raise_error( RuntimeError, 'dhcpd server failed to start - check syslog for diagnostics.' )
  end
end


describe Dhcp, 'when ipaddress is not determined' do
  it_should_behave_like 'dhcp with dummy nodes, dhcpd installed'


  it 'should raise when Dhcp.setup called' do
    Facter.stubs( :value ).with( 'ipaddress' ).returns( nil )

    lambda do
      Dhcp.setup
    end.should raise_error( "Cannnot resolve Lucie server's IP address." )
  end
end


describe Dhcp, 'when dommainname is not determined' do
  it_should_behave_like 'dhcp with dummy nodes, dhcpd installed'


  it 'should raise when Dhcp.setup called' do
    Facter.expects( :value ).with( 'domain' ).returns( nil )

    lambda do
      Dhcp.setup
    end.should raise_error( "Cannnot resolve Lucie server's domain name." )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
