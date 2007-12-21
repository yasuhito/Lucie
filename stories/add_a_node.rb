require 'stories/helper'


Story "Add a node with 'node' command",
%(As a cluster administrator
  I want to add a node using 'node' command
  So that I can add a node to the system) do


  # o lucied is [up] / down
  # o installer is [added] / not added
  # o node is [not added] / added

  Scenario 'node add succeeds' do
    Given 'lucied is started' do
      restart_lucied
    end

    Given 'No node is added' do
      cleanup_nodes
    end

    Given 'No installer is added' do
      cleanup_installers
    end

    Given 'TEST_NODE has a NIC' do
      @nic = Struct.new( :mac, :ip, :netmask, :gateway ).new
    end

    Given 'MAC address is', '00:00:00:00:00:00' do | mac_address |
      @nic.mac = mac_address
    end

    Given 'IP address is', '192.168.2.1' do | ip_address |
      @nic.ip = ip_address
    end

    Given 'Netmask address is', '255.255.255.0' do | netmask_address |
      @nic.netmask = netmask_address
    end

    Given 'Gateway address is', '192.168.2.254' do | gateway_address |
      @nic.gateway = gateway_address
    end

    Given 'TEST_INSTALLER is added' do
      system "./installer add TEST_INSTALLER --url https://lucie.is.titech.ac.jp/svn/trunk/config/demo"
    end

    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -a #{ @nic.ip } -n #{ @nic.netmask } -g #{ @nic.gateway } -m #{ @nic.mac }" do | command |
      # system command
      @stdout, @stderr = output_with( command )
    end

    Then 'MAC address file should be created with path =', './nodes/TEST_NODE/00_00_00_00_00_00' do | path |
      FileTest.exists?( path ).should be_true
    end

    Then 'installer file should be created with path =', './nodes/TEST_NODE/TEST_INSTALLER' do | path |
      # On Windows environment, the lucie:enable_node task invoked
      # from 'node add' command always fails, so installer file never created.
      FileTest.exists?( path ).should be_true
    end

    Then 'the contents of MAC address file should look like', %(
      gateway_address:192.168.2.254
      ip_address:192.168.2.1
      netmask_address:255.255.255.0
    ) do | contents |

      File.open( './nodes/TEST_NODE/00_00_00_00_00_00', 'r' ).read.split.should == contents.strip.split( /\s+/ )
    end
  end


  # o lucied is up / [down]
  # o installer is [added] / not added
  # o node is [not added] / added

  Scenario 'node add fails if lucie daemon is down' do
    Given 'lucied is stopped' do
      stop_lucied
    end

    Given 'No node is added'
    Given 'No installer is added'

    Given 'TEST_NODE has a NIC'
    Given 'MAC address is', '00:00:00:00:00:00'
    Given 'IP address is', '192.168.2.1'
    Given 'Netmask address is', '255.255.255.0'
    Given 'Gateway address is', '192.168.2.254'

    Given 'TEST_INSTALLER is added'

    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -a #{ @nic.ip } -n #{ @nic.netmask } -g #{ @nic.gateway } -m #{ @nic.mac }"

    Then 'the error message should be:', 'FAILED: Lucie daemon (lucied) is down.' do | error_message |
      @stderr.should == error_message
    end
  end


  # o lucied is [up] / down
  # o installer is added / [not added]
  # o node is [not added] / added

  Scenario 'node add fails if installer is not added' do
    Given 'lucied is started'
    Given 'No node is added'
    Given 'No installer is added'

    Given 'TEST_NODE has a NIC'
    Given 'MAC address is', '00:00:00:00:00:00'
    Given 'IP address is', '192.168.2.1'
    Given 'Netmask address is', '255.255.255.0'
    Given 'Gateway address is', '192.168.2.254'

    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -a #{ @nic.ip } -n #{ @nic.netmask } -g #{ @nic.gateway } -m #{ @nic.mac }"

    Then 'the error message should be:', "FAILED: installer 'TEST_INSTALLER' is not added yet." do | error_message |
      @stderr.should == error_message
    end
  end


  # o lucied is [up] / down
  # o installer [is added] / not added
  # o node is not added / [added]

  Scenario 'node add fails if a node of the same name is already added' do
    Given 'lucied is started'

    Given 'No node is added'
    Given 'No installer is added'

    Given 'TEST_NODE has a NIC'
    Given 'MAC address is', '00:00:00:00:00:00'
    Given 'IP address is', '192.168.2.1'
    Given 'Netmask address is', '255.255.255.0'
    Given 'Gateway address is', '192.168.2.254'

    Given 'TEST_INSTALLER is added'

    # add twice
    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -a #{ @nic.ip } -n #{ @nic.netmask } -g #{ @nic.gateway } -m #{ @nic.mac }"
    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -a #{ @nic.ip } -n #{ @nic.netmask } -g #{ @nic.gateway } -m #{ @nic.mac }"

    Then 'the error message should be:', 'FAILED: node named "TEST_NODE" already exists.' do | error_message |
      @stderr.should == error_message
    end
  end


  Scenario 'node add fails if IP address is missing' do
    Given 'No node is added'

    Given 'TEST_NODE has a NIC'
    Given 'MAC address is', '00:00:00:00:00:00'
    Given 'Netmask address is', '255.255.255.0'
    Given 'Gateway address is', '192.168.0.254'

    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -n #{ @nic.netmask } -g #{ @nic.gateway } -m #{ @nic.mac }"

    Then 'the error message matches with', /IP, Netmask, Gateway, and MAC address are mandatory/ do | regexp |
      @stderr.should match( regexp )
    end
  end


  Scenario 'node add fails if netmask address is missing' do
    Given 'No node is added'

    Given 'TEST_NODE has a NIC'
    Given 'IP address is', '192.168.0.1'
    Given 'MAC address is', '00:00:00:00:00:00'
    Given 'Gateway address is', '192.168.0.254'

    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -a #{ @nic.ip } -g #{ @nic.gateway } -m #{ @nic.mac }"

    Then 'the error message matches with', /IP, Netmask, Gateway, and MAC address are mandatory/
  end


  Scenario 'node add fails if gateway address is missing' do
    Given 'No node is added'

    Given 'TEST_NODE has a NIC'
    Given 'IP address is', '192.168.0.1'
    Given 'Netmask address is', '255.255.255.0'
    Given 'MAC address is', '00:00:00:00:00:00'

    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -a #{ @nic.ip } -n #{ @nic.netmask } -m #{ @nic.mac }"

    Then 'the error message matches with', /IP, Netmask, Gateway, and MAC address are mandatory/
  end


  Scenario 'node add fails if MAC address is missing' do
    Given 'No node is added'

    Given 'TEST_NODE has a NIC'
    Given 'IP address is', '192.168.0.1'
    Given 'Netmask address is', '255.255.255.0'
    Given 'Gateway address is', '192.168.0.254'

    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -a #{ @nic.ip } -n #{ @nic.netmask } -g #{ @nic.gateway }"

    Then 'the error message matches with', /IP, Netmask, Gateway, and MAC address are mandatory/
  end
end


Story 'Trace node add command',
%(As a cluster administrator
  I can trace a failed command
  So that I can report detailed backtrace to Lucie developers) do

  Scenario 'run node add with --trace option' do
    Given './nodes/TEST_NODE already exists' do
      add_fresh_node 'TEST_NODE'
    end

    When "I run 'node add' with --trace option" do
      @stdout, @stderr = output_with( './node add TEST_NODE --installer TEST_INSTALLER -a 192.168.0.1 -n 255.255.255.0 -g 192.168.0.254 -m 00:00:00:00:00:00 --trace' )
    end

    Then 'I get an error and backtrace message' do
      @stderr.should match( /from/ )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
