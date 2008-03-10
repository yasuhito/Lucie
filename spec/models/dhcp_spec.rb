require File.dirname( __FILE__ ) + '/../spec_helper'


describe Dhcp, 'when setting up DHCP server' do
  before( :each ) do
    @dhcp = Dhcp.new
    Dhcp.stubs( :new ).returns( @dhcp )
  end


  it 'should be able to setup DHCP' do
    # expects
    File.expects( :copy )
    File.expects( :open ).yields( dhcp_config_file )

    Nodes.expects( :load_all ).returns( [ dummy_node ] ).at_least_once

    @dhcp.expects( :domain )
    @dhcp.expects( :ipaddress )
    @dhcp.expects( :sh_exec )

    # when
    lambda do
      Dhcp.setup

      # then
    end.should_not raise_error
  end


  it 'should raise error if /etc/init.d/dhcp3-server restart failed' do
    # expects
    File.expects( :copy )
    File.expects( :open ).yields( dhcp_config_file )

    Nodes.expects( :load_all ).returns( [ dummy_node ] ).at_least_once

    @dhcp.expects( :domain )
    @dhcp.expects( :ipaddress )
    @dhcp.stubs( :sh_exec ).raises( RuntimeError )

    lambda do
      Dhcp.setup
    end.should raise_error( RuntimeError, 'dhcpd server failed to start - check syslog for diagnostics.' )
  end


  def dummy_node
    node = Object.new
    node.stubs( :enable? ).returns( true )
    node.stubs( :gateway_address).returns( '192.168.1.254' )
    node.stubs( :ip_address ).returns( '192.168.1.10' )
    node.stubs( :mac_address ).returns( 'MAC_ADDRESS' )
    node.stubs( :name ).returns( 'DUMMY_NODE' )
    node.stubs( :netmask_address ).returns( '255.255.255.0' )
    node
  end


  def dhcp_config_file
    file = Object.new
    file.stubs( :puts )
    file
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
