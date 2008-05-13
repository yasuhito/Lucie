require File.dirname( __FILE__ ) + '/../spec_helper'
require 'rake'


describe 'Common Node', :shared => true do
  include FileSandbox


  def network_option options = { }
    default = { :mac_address => '11:22:33:44:55:66', :gateway_address => '192.168.1.254', :ip_address => '192.168.1.1', :netmask_address => '255.255.255.0' }
    options.each_pair do | key, value |
      default[ key ] = value
    end
    default
  end


  def network_config
    <<-EOF
gateway_address:192.168.1.254
ip_address:192.168.1.1
netmask_address:255.255.255.0
EOF
  end
end


describe Node, 'when creating a new node' do
  it_should_behave_like 'Common Node'


  it 'should be successfully created' do
    # when
    node = Node.new( 'TEST_NODE', network_option )

    # then
    node.name.should == 'TEST_NODE'
    node.mac_address.should == '11:22:33:44:55:66'
    node.gateway_address.should == '192.168.1.254'
    node.ip_address == '192.168.1.1'
    node.netmask_address == '255.255.255.0'
  end


  it 'should be created from existing node directory' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER'
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config

      # when
      node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )

      # then
      node.installer_name.should == 'TEST_INSTALLER'
      node.name.should == 'TEST_NODE'
      node.mac_address.should == '11:22:33:44:55:66'
      node.gateway_address.should == '192.168.1.254'
      node.ip_address == '192.168.1.1'
      node.netmask_address == '255.255.255.0'
    end
  end


  it 'should fail if MAC file does not contain network config' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER'

      lambda do
        # when
        Node.read( File.join( sandbox.root, 'TEST_NODE' ) )

        # then
      end.should raise_error( "MAC address for node 'TEST_NODE' not defined." )
    end
  end
end


describe Node, 'when creating a new node (mandatory network option is not set)' do
  it_should_behave_like 'Common Node'


  it 'should raise if name is not set' do
    lambda do
      # when
      Node.new( nil, network_option )

      # then
    end.should raise_error( "name is mandatory." )
  end


  it 'should raise if MAC address is not set' do
    lambda do
      # when
      Node.new( 'NODE_NAME', network_option( { :mac_address => nil } ) )

      # then
    end.should raise_error( "MAC address is mandatory." )
  end


  it 'should raise if gateway address is not set' do
    lambda do
      # when
      Node.new( 'NODE_NAME', network_option( { :gateway_address => nil } ) )

      # then
    end.should raise_error( "Gateway address is mandatory." )
  end


  it 'should raise if IP address is not set' do
    lambda do
      # when
      Node.new( 'NODE_NAME', network_option( { :ip_address => nil } ) )

      # then
    end.should raise_error( "IP address is mandatory." )
  end


  it 'should raise if netmask address is not set' do
    lambda do
      # when
      Node.new( 'NODE_NAME', network_option( { :netmask_address => nil } ) )

      # then
    end.should raise_error( "Netmask address is mandatory." )
  end
end


describe Node, 'when creating a new node (invalid network option)' do
  it_should_behave_like 'Common Node'


  it 'should raise if invalid name' do
    invalid_chars = %q(~!@#$%^&*()+{};'\[]=:"|<>?) #'

    invalid_chars.split( // ).each do | each |
      lambda do
        # when
        Node.new( each, network_option )

        # then
      end.should raise_error( "'#{ each }' is not a valid node name." )
    end
  end


  it 'should raise if invalid MAC address' do
    lambda do
      # when
      Node.new( 'NODE_NAME', network_option( :mac_address => 'INVALID_MAC_ADDRESS' ) )

      # then
    end.should raise_error( "'INVALID_MAC_ADDRESS' is not a valid MAC address." )
  end


  it 'should raise if invalid gateway address' do
    lambda do
      # when
      Node.new( 'NODE_NAME', network_option( :gateway_address => 'INVALID_GATEWAY_ADDRESS' ) )

      # then
    end.should raise_error( "'INVALID_GATEWAY_ADDRESS' is not a valid gateway address." )
  end


  it 'should raise if invalid IP address' do
    lambda do
      # when
      Node.new( 'NODE_NAME', network_option( :ip_address => 'INVALID_IP_ADDRESS' ) )

      # then
    end.should raise_error( "'INVALID_IP_ADDRESS' is not a valid IP address." )
  end


  it 'should raise if invalid netmask address' do
    lambda do
      # when
      Node.new( 'NODE_NAME', network_option( :netmask_address => 'INVALID_NETMASK_ADDRESS' ) )

      # then
    end.should raise_error( "'INVALID_NETMASK_ADDRESS' is not a valid netmask address." )
  end
end


describe 'lucie:add_node task', :shared => true do
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
end


describe Node, 'when adding a new node with lucie:add_node rake task' do
  it_should_behave_like 'lucie:add_node task'


  it 'should add a new node' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )

      # when
      load "#{ RAILS_ROOT }/lib/tasks/add_node.rake"
      Rake::Task[ 'lucie:add_node' ].execute nil

      # then
      Nodes.load_all.list.size.should == 1
      node = Nodes.load_all.list[ 0 ]
      node.name.should == 'TEST_NODE'
      node.mac_address.should == '11:22:33:44:55:66'
      node.gateway_address.should == '192.168.1.254'
      node.ip_address == '192.168.1.1'
      node.netmask_address == '255.255.255.0'
    end
  end
end


describe Node, 'when adding a same node twice with lucie:add_node rake task' do
  it_should_behave_like 'lucie:add_node task'


  it 'should raise when adding the same node' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      load "#{ RAILS_ROOT }/lib/tasks/add_node.rake"

      # given
      Rake::Task[ 'lucie:add_node' ].execute nil

      # when
      lambda do
        Rake::Task[ 'lucie:add_node' ].execute nil

        # then
      end.should raise_error( "Node 'TEST_NODE' already exists." )
    end
  end
end


describe Node, 'when creating a new node with lucie:add_node rake task (mandatory ENVs are not set)' do
  it_should_behave_like 'lucie:add_node task'


  it 'should raise if name is not set' do
    lambda do
      # when
      load "#{ RAILS_ROOT }/lib/tasks/add_node.rake"
      ENV[ 'NODE_NAME' ] = nil
      Rake::Task[ 'lucie:add_node' ].execute nil

      # then
    end.should raise_error( MandatoryOptionError, "Node name not defined." )
  end


  it 'should raise if MAC address is not set' do
    lambda do
      # when
      load "#{ RAILS_ROOT }/lib/tasks/add_node.rake"
      ENV[ 'MAC_ADDRESS' ] = nil
      Rake::Task[ 'lucie:add_node' ].execute nil

      # then
    end.should raise_error( MandatoryOptionError, "MAC address for node 'TEST_NODE' not defined." )
  end


  it 'should raise if IP address is not set' do
    lambda do
      # when
      load "#{ RAILS_ROOT }/lib/tasks/add_node.rake"
      ENV[ 'IP_ADDRESS' ] = nil
      Rake::Task[ 'lucie:add_node' ].execute nil

      # then
    end.should raise_error( MandatoryOptionError, "IP address for node 'TEST_NODE' not defined." )
  end


  it 'should raise if gateway address is not set' do
    lambda do
      # when
      load "#{ RAILS_ROOT }/lib/tasks/add_node.rake"
      ENV[ 'GATEWAY_ADDRESS' ] = nil
      Rake::Task[ 'lucie:add_node' ].execute nil

      # then
    end.should raise_error( MandatoryOptionError, "Gateway address for node 'TEST_NODE' not defined." )
  end


  it 'should raise if netmask address is not set' do
    lambda do
      # when
      load "#{ RAILS_ROOT }/lib/tasks/add_node.rake"
      ENV[ 'NETMASK_ADDRESS' ] = nil
      Rake::Task[ 'lucie:add_node' ].execute nil

      # then
    end.should raise_error( MandatoryOptionError, "Netmask address for node 'TEST_NODE' not defined." )
  end
end


describe Node, 'when enabling a node with lucie:enable_node rake task' do
  before( :each ) do
    Rake::Task.clear

    ENV[ 'NODE_NAME' ] = 'TEST_NODE'
    ENV[ 'INSTALLER_NAME' ] = 'TEST_INSTALLER'
    ENV[ 'WOL' ] = 'WOL'
  end


  after( :each ) do
    Rake::Task.clear

    ENV[ 'NODE_NAME' ] = nil
    ENV[ 'INSTALLER_NAME' ] = nil
    ENV[ 'WOL' ] = nil
  end


  it 'should enable installation for a node' do
    lucie_daemon = Object.new
    Lucie::Log.stubs( :debug )
    Nodes.stubs( :find ).returns( true )
    Installers.stubs( :find ).returns( true )

    # expects
    Nodes.stubs( :find ).with( 'TEST_NODE').returns( true )
    Installers.stubs( :find ).with( 'TEST_INSTALLER' ).returns( true )

    LucieDaemon.expects( :server ).returns( lucie_daemon )

    #lucie_daemon.expects( :enable_node ).with( 'TEST_NODE', 'TEST_INSTALLER' )
    lucie_daemon.expects( :enable_nodes ).with( 'TEST_NODE', 'TEST_INSTALLER' )
    lucie_daemon.expects( :setup_tftp ).with( 'TEST_NODE', 'TEST_INSTALLER' )
    lucie_daemon.expects( :setup_nfs )
    lucie_daemon.expects( :setup_dhcp )
    lucie_daemon.expects( :setup_puppet ).with( 'TEST_INSTALLER' )
    lucie_daemon.expects( :wol ).with( 'TEST_NODE' )

    pending
    # when
    lambda do
      load "#{ RAILS_ROOT }/lib/tasks/enable_node.rake"
      Rake::Task[ 'lucie:enable_node' ].execute

      # then
    end.should_not raise_error
  end
end


describe Node, 'when enabling a node with lucie:enable_node rake task (mandatory ENVs are not set)' do
  it 'should raise if NODE_NAME is not set' do
    lambda do
      # when
      load "#{ RAILS_ROOT }/lib/tasks/enable_node.rake"
      ENV[ 'NODE_NAME' ] = nil
      Rake::Task[ 'lucie:enable_node' ].execute nil

      # then
    end.should raise_error( "Node name not defined." )
  end


  it 'should raise if INSTALLER_NAME is not set' do
    pending

    lambda do
      # when
      load "#{ RAILS_ROOT }/lib/tasks/enable_node.rake"
      ENV[ 'NODE_NAME' ] = 'TEST_NODE'
      ENV[ 'INSTALLER_NAME' ] = nil
      Rake::Task[ 'lucie:enable_node' ].execute nil

      # then
    end.should raise_error( "Installer name for node 'TEST_NODE' not defined." )
  end
end


describe Node, 'when detecting node is enabled or not' do
  it_should_behave_like 'Common Node'


  it 'should be enable if `installer_name` file exist' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER'
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config

      # given
      node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )

      # when, then
      node.should be_enable
    end
  end


  it 'should not be enable if `installer_name.DISABLE` file exist' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER.DISABLE'
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config

      # given
      node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )

      # when, then
      node.should_not be_enable
    end
  end


  it 'should not be enable if `installer_name` file does not exist' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config

      # given
      node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )

      # when, then
      node.should_not be_enable
    end
  end
end


describe Node, 'when enabling / disabling a node' do
  it_should_behave_like 'Common Node'


  it 'should create a empty `installer_name` file when calling Node#enable!' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config

      # when
      node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )
      node.enable!( 'TEST_INSTALLER' )

      # then
      Dir[ File.join( sandbox.root, 'TEST_NODE', '*' ) ].size.should == 2
      File.exists?( File.join( sandbox.root, 'TEST_NODE/11_22_33_44_55_66' ) ).should == true
      File.exists?( File.join( sandbox.root, 'TEST_NODE/TEST_INSTALLER' ) ).should == true
    end
  end


  it 'should rename `old_installer_name` to `new_installer_name` file when calling Node#enable!' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/OLD_TEST_INSTALLER'
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config

      # when
      node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )
      node.enable!( 'NEW_TEST_INSTALLER' )

      # then
      Dir[ File.join( sandbox.root, 'TEST_NODE', '*' ) ].size.should == 2
      File.exists?( File.join( sandbox.root, 'TEST_NODE/11_22_33_44_55_66' ) ).should == true
      File.exists?( File.join( sandbox.root, 'TEST_NODE/NEW_TEST_INSTALLER' ) ).should == true
    end
  end


  it 'should rename `old_installer_name.DISABLE` to `installer_name` file when calling Node#enable!' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/OLD_TEST_INSTALLER.DISABLE'
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config

      # when
      node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )
      node.enable!( 'NEW_TEST_INSTALLER' )

      # then
      Dir[ File.join( sandbox.root, 'TEST_NODE', '*' ) ].size.should == 2
      File.exists?( File.join( sandbox.root, 'TEST_NODE/11_22_33_44_55_66' ) ).should == true
      File.exists?( File.join( sandbox.root, 'TEST_NODE/NEW_TEST_INSTALLER' ) ).should == true
    end
  end


  it 'should rename `installer_name` file to `installer_name.DISABLE` when calling Node#disable!' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER'
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config

      # when
      node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )
      node.disable!

      # then
      File.exists?( File.join( sandbox.root, 'TEST_NODE/TEST_INSTALLER.DISABLE' ) ).should == true
    end
  end
end


describe Node, 'when accessing installer_name of disabled node' do
  it_should_behave_like 'Common Node'


  it 'should be created from existing node directory' do
    in_sandbox do | sandbox |
      # given
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER.DISABLE'

      # when
      node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )

      # then
      node.installer_name.should == 'TEST_INSTALLER'
    end
  end
end


describe Node, 'when accessing install history' do
  it_should_behave_like 'Common Node'


  def setup_installs sandbox
    sandbox.new :file => 'TEST_NODE/install-0/install_status.success'
    sandbox.new :file => 'TEST_NODE/install-1/install_status.success'
    sandbox.new :file => 'TEST_NODE/install-2/install_status.success'
    sandbox.new :file => 'TEST_NODE/install-3/install_status.success'
    sandbox.new :file => 'TEST_NODE/install-4/install_status.success'
    sandbox.new :file => 'TEST_NODE/install-5/install_status.success'
    sandbox.new :file => 'TEST_NODE/install-6/install_status.success'
    sandbox.new :file => 'TEST_NODE/install-7/install_status.success'
    sandbox.new :file => 'TEST_NODE/install-8/install_status.success'
    sandbox.new :file => 'TEST_NODE/install-9/install_status.success'
  end


  it 'should have installation history' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER'

      # given
      setup_installs sandbox
      @node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )

      # when
      installs = @node.installs

      # then
      installs.size.should == 10
      installs[ 0 ].label.should == 0
      installs[ 1 ].label.should == 1
      installs[ 2 ].label.should == 2
      installs[ 3 ].label.should == 3
      installs[ 4 ].label.should == 4
      installs[ 5 ].label.should == 5
      installs[ 6 ].label.should == 6
      installs[ 7 ].label.should == 7
      installs[ 8 ].label.should == 8
      installs[ 9 ].label.should == 9
    end
  end


  it 'should have last five installation history' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER'

      # given
      setup_installs sandbox
      @node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )

      # when
      last_five_installs = @node.last_five_installs

      # then
      last_five_installs.size.should == 5
      last_five_installs[ 0 ].label.should == 9
      last_five_installs[ 1 ].label.should == 8
      last_five_installs[ 2 ].label.should == 7
      last_five_installs[ 3 ].label.should == 6
      last_five_installs[ 4 ].label.should == 5
    end
  end


  it 'should have the latest install' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER'

      # given
      setup_installs sandbox
      @node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )

      # when, then
      @node.last_complete_install_status.should == 'success'
    end
  end


  it 'should have the last complete install status' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER'

      # given
      setup_installs sandbox
      @node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )

      # when, then
      @node.latest_install.label.should == 9
    end
  end


  it 'should not have the last complete install status if there are no install' do
    in_sandbox do | sandbox |
      Configuration.stubs( :nodes_directory ).returns( sandbox.root )
      sandbox.new :file => 'TEST_NODE/11_22_33_44_55_66', :with_contents => network_config
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER'

      # given
      @node = Node.read( File.join( sandbox.root, 'TEST_NODE' ) )

      # when, then
      @node.last_complete_install.should be_nil
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
