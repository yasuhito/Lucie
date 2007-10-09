require File.dirname( __FILE__ ) + '/../spec_helper'


describe 'All Nodes', :shared => true do
  include FileSandbox


  def node_1_network_config
    <<-EOF
gateway_address:192.168.1.254
ip_address:192.168.1.1
netmask_address:255.255.255.0
EOF
  end


  def node_2_network_config
    <<-EOF
gateway_address:192.168.1.254
ip_address:192.168.1.2
netmask_address:255.255.255.0
EOF
  end


  def node_3_network_config
    <<-EOF
gateway_address:192.168.1.254
ip_address:192.168.1.3
netmask_address:255.255.255.0
EOF
  end


  def node_4_network_config
    <<-EOF
gateway_address:192.168.1.254
ip_address:192.168.1.4
netmask_address:255.255.255.0
EOF
  end


  def node_5_network_config
    <<-EOF
gateway_address:192.168.1.254
ip_address:192.168.1.5
netmask_address:255.255.255.0
EOF
  end
end


describe Nodes, 'when never installed' do
  it_should_behave_like 'All Nodes'


  it 'gives summary that never installed' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )

      Nodes.summary( 'INSTALLER_NAME' ).should == 'Never installed'
    end
  end
end


describe Nodes, 'when not all nodes are successfully installed' do
  it_should_behave_like 'All Nodes'


  it 'gives summary that reflects each install status' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )

      sandbox.new :file => 'NODE-1/INSTALLER_NAME'
      sandbox.new :file => 'NODE-1/00_00_00_00_00_01', :with_contents => node_1_network_config
      sandbox.new :file => 'NODE-1/install-10/install_status.success'

      sandbox.new :file => 'NODE-2/INSTALLER_NAME'
      sandbox.new :file => 'NODE-2/00_00_00_00_00_02', :with_contents => node_2_network_config
      sandbox.new :file => 'NODE-2/install-20/install_status.success'

      sandbox.new :file => 'NODE-3/INSTALLER_NAME'
      sandbox.new :file => 'NODE-3/00_00_00_00_00_03', :with_contents => node_3_network_config
      sandbox.new :file => 'NODE-3/install-30/install_status.failed'

      sandbox.new :file => 'NODE-4/INSTALLER_NAME'
      sandbox.new :file => 'NODE-4/00_00_00_00_00_04', :with_contents => node_4_network_config
      sandbox.new :file => 'NODE-4/install-40/install_status.incomplete'

      sandbox.new :file => 'NODE-5/OTHER_INSTALLER_NAME'
      sandbox.new :file => 'NODE-5/00_00_00_00_00_05', :with_contents => node_5_network_config
      sandbox.new :file => 'NODE-5/install-50/install_status.incomplete'

      assert_equal '1 FAIL, 1 incomplete', Nodes.summary( 'INSTALLER_NAME' )
    end
  end
end


describe Nodes, 'when all nodes are successfully installed' do
  it_should_behave_like 'All Nodes'


  it 'gives summary OK' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )

      sandbox.new :file => 'NODE_1/INSTALLER_NAME'
      sandbox.new :file => 'NODE_1/11_22_33_44_55_66', :with_contents => node_1_network_config
      sandbox.new :file => 'NODE_1/install-10/install_status.success'

      sandbox.new :file => 'NODE_2/INSTALLER_NAME'
      sandbox.new :file => 'NODE_2/66_55_44_33_22_11', :with_contents => node_2_network_config
      sandbox.new :file => 'NODE_2/install-20/install_status.success'

      Nodes.summary( 'INSTALLER_NAME' ).should == 'OK'
    end
  end
end
