require File.dirname( __FILE__ ) + '/../spec_helper'
require 'rake'


describe Node, 'when creating a new node from custom rake task' do
  include FileSandbox


  before( :each ) do
    Rake::Task.clear
    STDOUT.stubs( :puts )
    ENV[ 'NODE_NAME' ] = 'TEST_NODE'
    ENV[ 'MAC_ADDRESS' ] = '11:22:33:44:55:66'
    ENV[ 'IP_ADDRESS' ] = '192.168.1.1'
    ENV[ 'GATEWAY_ADDRESS' ] = '192.168.1.254'
    ENV[ 'NETMASK_ADDRESS' ] = '255.255.255.0'
  end


  after( :each ) do
    ENV[ 'NODE_NAME' ] = nil
    ENV[ 'MAC_ADDRESS' ] = nil
    ENV[ 'IP_ADDRESS' ] = nil
    ENV[ 'GATEWAY_ADDRESS' ] = nil
    ENV[ 'NETMASK_ADDRESS' ] = nil
  end


  it 'should add a new node' do
    load './lib/tasks/add_node.rake'
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      Rake::Task[ 'lucie:add_node' ].invoke

      Nodes.load_all.list.size.should == 1
      node = Nodes.load_all.list[ 0 ]
      node.name.should == 'TEST_NODE'
      node.mac_address.should == '11:22:33:44:55:66'
      node.gateway_address.should == '192.168.1.254'
      node.ip_address == '192.168.1.1'
      node.netmask_address == '255.255.255.0'
    end
  end


  it 'should raise if MAC address is not set' do
    load './lib/tasks/add_node.rake'
    ENV[ 'MAC_ADDRESS' ] = nil

    lambda do
      Rake::Task[ 'lucie:add_node' ].invoke
    end.should raise_error( RuntimeError, "MAC address for node 'TEST_NODE' not defined." )
  end


  it 'should raise if IP address is not set' do
    load './lib/tasks/add_node.rake'
    ENV[ 'IP_ADDRESS' ] = nil

    lambda do
      Rake::Task[ 'lucie:add_node' ].invoke
    end.should raise_error( RuntimeError, "IP address for node 'TEST_NODE' not defined." )
  end


  it 'should raise if gateway address is not set' do
    load './lib/tasks/add_node.rake'
    ENV[ 'GATEWAY_ADDRESS' ] = nil

    lambda do
      Rake::Task[ 'lucie:add_node' ].invoke
    end.should raise_error( RuntimeError, "Gateway address for node 'TEST_NODE' not defined." )
  end


  it 'should raise if netmask address is not set' do
    load './lib/tasks/add_node.rake'
    ENV[ 'NETMASK_ADDRESS' ] = nil

    lambda do
      Rake::Task[ 'lucie:add_node' ].invoke
    end.should raise_error( RuntimeError, "Netmask address for node 'TEST_NODE' not defined." )
  end
end


describe Node, 'when creating a new node' do
  it 'should raise if MAC address is not set' do
    lambda do
      Node.new( 'TEST_NODE', :gateway_address => '192.168.1.254', :ip_address => '192.168.1.1', :netmask_address => '255.255.255.0' )
    end.should raise_error( RuntimeError, "MAC address for node 'TEST_NODE' not defined." )
  end


  it 'should raise if IP address is not set' do
    lambda do
      Node.new( 'TEST_NODE', :mac_address => '11:22:33:44:55:66', :gateway_address => '192.168.1.254', :netmask_address => '255.255.255.0' )
    end.should raise_error( RuntimeError, "IP address for node 'TEST_NODE' not defined." )
  end


  it 'should raise if gateway address is not set' do
    lambda do
      Node.new( 'TEST_NODE', :mac_address => '11:22:33:44:55:66', :ip_address => '192.168.1.1', :netmask_address => '255.255.255.0' )
    end.should raise_error( RuntimeError, "Gateway address for node 'TEST_NODE' not defined." )
  end


  it 'should raise if netmask address is not set' do
    lambda do
      Node.new( 'TEST_NODE', :mac_address => '11:22:33:44:55:66', :gateway_address => '192.168.1.254', :ip_address => '192.168.1.1' )
    end.should raise_error( RuntimeError, "Netmask address for node 'TEST_NODE' not defined." )
  end
end


describe Node do
  include FileSandbox


  it 'should have network settings' do
    node = Node.new( 'TEST_NODE', :mac_address => '11:22:33:44:55:66', :gateway_address => '192.168.1.254', :ip_address => '192.168.1.1', :netmask_address => '255.255.255.0' )

    node.name.should == 'TEST_NODE'
    node.mac_address.should == '11:22:33:44:55:66'
    node.gateway_address.should == '192.168.1.254'
    node.ip_address == '192.168.1.1'
    node.netmask_address == '255.255.255.0'
  end


  it 'should be able to load network settings' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/11:22:33:44:55:66', :with_contents => mac_address_file

      node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )
      node.name.should == 'TEST_NODE'
      node.mac_address.should == '11:22:33:44:55:66'
      node.gateway_address.should == '192.168.1.254'
      node.ip_address == '192.168.1.1'
      node.netmask_address == '255.255.255.0'
    end
  end


  def mac_address_file
    <<-EOF
gateway_address:192.168.1.254
ip_address:192.168.1.1
netmask_address:255.255.255.0
EOF
  end
end
