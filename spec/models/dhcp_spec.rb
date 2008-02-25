require File.dirname( __FILE__ ) + '/../spec_helper'


describe Dhcp, 'when resolving domain name' do
  it 'should resolve domain name' do
    Facter.stubs( :value ).with( 'domain' ).returns( 'DOMAIN' )

    Dhcp.new.domain.should == 'DOMAIN'
  end


  it 'should fail if failed to resolve domain name' do
    Facter.stubs( :value ).with( 'domain' ).returns( false )

    lambda do
      Dhcp.new.domain
    end.should raise_error( RuntimeError, "Cannnot resolve Lucie server's domain name." )
  end
end


describe Dhcp, 'when resolving IP address of Lucie server' do
  it 'should resolve IP address of Lucie server' do
    Facter.stubs( :value ).with( 'ipaddress' ).returns( '192.168.1.100' )

    Dhcp.new.ipaddress.should == '192.168.1.100'
  end


  it 'should fail if failed to resolve IP address of Lucie server' do
    Facter.stubs( :value ).with( 'ipaddress' ).returns( false )

    lambda do
      Dhcp.new.ipaddress
    end.should raise_error( RuntimeError, "Cannnot resolve Lucie server's IP address." )
  end
end


describe Dhcp, 'when resolving IP address of a node' do
  before( :each ) do
    @node = Object.new
  end


  it 'should resolve IP address of a node' do
    @node.stubs( :ip_address ).returns( '192.168.1.1' )
    Nodes.stubs( :find ).returns @node

    Dhcp.new.node_ipaddress( 'NODE_NAME' ).should == '192.168.1.1'
  end


  it 'should fail if failed to resolve IP address of a node' do
    @node.stubs( :ip_address ).returns( false )
    Nodes.stubs( :find ).returns @node

    lambda do
      Dhcp.new.node_ipaddress 'NODE_NAME'
    end.should raise_error( "Cannnot resolve host 'NODE_NAME' IP address." )
  end
end


describe Dhcp, 'when setting up DHCP server' do
  it 'should be able to setup DHCP' do
    File.stubs( :copy )
    File.stubs( :open ).yields( dhcp_config_file )

    dhcp = Dhcp.new
    dhcp.stubs( :domain )
    dhcp.stubs( :ipaddress )
    dhcp.stubs( :node_ipaddress )
    dhcp.stubs( :sh_exec )
    Dhcp.stubs( :new ).returns( dhcp )

    Nodes.stubs( :load_enabled ).returns( [ dummy_node ] )

    lambda do
      Dhcp.setup 'TEST_INSTALLER', '192.168.1.1', '255.255.255.0', '192.168.1.2'
    end.should_not raise_error
  end


  it 'should raise error if /etc/init.d/dhcp3-server restart failed' do
    File.stubs( :copy )
    File.stubs( :open ).yields( dhcp_config_file )

    dhcp = Dhcp.new
    dhcp.stubs( :domain )
    dhcp.stubs( :ipaddress )
    dhcp.stubs( :node_ipaddress )
    dhcp.stubs( :sh_exec ).raises( RuntimeError )
    Dhcp.stubs( :new ).returns( dhcp )

    Nodes.stubs( :load_enabled ).returns( [ dummy_node ] )

    lambda do
      Dhcp.setup 'TEST_INSTALLER', '192.168.1.1', '255.255.255.0', '192.168.1.2'
    end.should raise_error( RuntimeError, 'dhcpd server failed to start - check syslog for diagnostics.' )
  end


  def dummy_node
    node = Object.new
    node.stubs( :name ).returns( 'DUMMY_NODE' )
    node.stubs( :mac_address ).returns( 'MAC_ADDRESS' )
    node
  end


  def dhcp_config_file
    dhcp_config_file = Object.new
    dhcp_config_file.stubs( :puts )
    dhcp_config_file
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
