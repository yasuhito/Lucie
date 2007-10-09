require File.dirname( __FILE__ ) + '/../spec_helper'


describe Dhcp, 'when setting up DHCP server' do
  it 'should be able to setup DHCP' do
    File.stubs( :copy )
    file = Object.new
    file.stubs( :puts )
    File.stubs( :open ).yields( file )

    dhcp = Dhcp.new
    Dhcp.stubs( :new ).returns( dhcp )
    dhcp.stubs( :domain )
    dhcp.stubs( :ipaddress )
    dhcp.stubs( :sh_exec )

    lambda do
      Dhcp.setup 'TEST_INSTALLER', '192.168.1.1', '255.255.255.0', '192.168.1.2'
    end.should_not raise_error
  end


  it 'should fail if failed to resolve domain name' do
    Facter.stubs( :value ).with( 'domain' ).returns( false )

    lambda do
      Dhcp.new.domain
    end.should raise_error( RuntimeError, "Cannnot resolve Lucie server's domain name." )
  end


  it 'should fail if failed to resolve ipaddress of Lucie server' do
    Facter.stubs( :value ).with( 'ipaddress' ).returns( false )

    lambda do
      Dhcp.new.ipaddress
    end.should raise_error( RuntimeError, "Cannnot resolve Lucie server's IP address." )
  end


  it 'should fail if failed to resolve ip address of node' do
    resolver = Object.new
    resolver.stubs( :getaddress ).with( 'NODE_NAME' ).returns( false )
    Resolv::Hosts.stubs( :new ).returns( resolver )

    lambda do
      Dhcp.new.node_ipaddress 'NODE_NAME'
    end.should raise_error( "Cannnot resolve host 'NODE_NAME' IP address." )
  end
end
