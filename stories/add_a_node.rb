require 'rubygems'

require 'open3'
require 'rbehave'
require 'spec'


Story "Read the 'node add' help message", %(
  As a cluster administrator
  I want to read help message of 'node add'
  So that I can understand how to add a node to the system) do


  Scenario 'node help add' do
    When 'I run', './node help add' do | command |
      @help_message = output_with( command ).split
    end

    Then 'the help message should look like', expected_help_message do | message |
      @help_message.should == message.strip.split( /\s+/ )
    end
  end

  Scenario 'node add --help' do
    When 'I run', './node add --help'
    Then 'the help message should look like', expected_help_message
  end

  Scenario 'node add -h' do
    When 'I run', './node add -h'
    Then 'the help message should look like', expected_help_message
  end
end


Story "Add a node with 'node' command",
%(As a cluster administrator
  I want to add a node using 'node' command
  So that I can add a node to the system) do

  Scenario 'node add success' do
    Given 'TEST_NODE is not added yet' do
      system( './node remove TEST_NODE 2>&1 >/dev/null' )
    end

    Given 'TEST_NODE has a NIC' do
      @nic = Struct.new( :mac, :ip, :netmask, :gateway ).new
    end

    Given 'MAC address is', '00:00:00:00:00:00' do | mac_address |
      @nic.mac = mac_address
    end

    Given 'IP address is', '192.168.0.1' do | ip_address |
      @nic.ip = ip_address
    end

    Given 'Netmask address is', '255.255.255.0' do | netmask_address |
      @nic.netmask = netmask_address
    end

    Given 'Gateway address is', '192.168.0.254' do | gateway_address |
      @nic.gateway = gateway_address
    end

    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -a #{ @nic.ip } -n #{ @nic.netmask } -g #{ @nic.gateway } -m #{ @nic.mac }" do | command |
      @error_message = output_with( command )
    end
    
    Then 'MAC address file should be created with path =', './nodes/TEST_NODE/00_00_00_00_00_00' do | path |
      FileTest.exists?( path ).should be_true
    end

    Then 'the contents of MAC address file should look like', %(
      gateway_address:192.168.0.254
      ip_address:192.168.0.1
      netmask_address:255.255.255.0
    ) do | contents |
      File.open( './nodes/TEST_NODE/00_00_00_00_00_00', 'r' ).read.split.should == contents.strip.split( /\s+/ )
    end
  end

  Scenario 'node add fails if IP address is missing' do
    Given 'TEST_NODE is not added yet'

    Given 'TEST_NODE has a NIC'

    Given 'MAC address is', '00:00:00:00:00:00'
    Given 'Netmask address is', '255.255.255.0'
    Given 'Gateway address is', '192.168.0.254'

    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -n #{ @nic.netmask } -g #{ @nic.gateway } -m #{ @nic.mac }"

    Then 'the error message matches with', /IP, Netmask, Gateway, and MAC address are mandatory/ do | regexp |
      @error_message.should match( regexp )
    end
  end

  Scenario 'node add fails if netmask address is missing' do
    Given 'TEST_NODE is not added yet'

    Given 'TEST_NODE has a NIC'

    Given 'IP address is', '192.168.0.1'
    Given 'MAC address is', '00:00:00:00:00:00'
    Given 'Gateway address is', '192.168.0.254'

    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -a #{ @nic.ip } -g #{ @nic.gateway } -m #{ @nic.mac }"

    Then 'the error message matches with', /IP, Netmask, Gateway, and MAC address are mandatory/
  end

  Scenario 'node add fails if gateway address is missing' do
    Given 'TEST_NODE is not added yet'

    Given 'TEST_NODE has a NIC'

    Given 'IP address is', '192.168.0.1'
    Given 'Netmask address is', '255.255.255.0'
    Given 'MAC address is', '00:00:00:00:00:00'

    When 'I add TEST_NODE with', "./node add TEST_NODE --installer TEST_INSTALLER -a #{ @nic.ip } -n #{ @nic.netmask } -m #{ @nic.mac }"

    Then 'the error message matches with', /IP, Netmask, Gateway, and MAC address are mandatory/
  end

  Scenario 'node add fails if MAC address is missing' do
    Given 'TEST_NODE is not added yet'

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
    Given 'TEST_NODE is already added' do
      system( 'mkdir ./nodes/TEST_NODE' )
    end

    When 'I run a command that fails with --trace option' do
      @error_message = output_with( "./node add TEST_NODE --installer TEST_INSTALLER -a 192.168.0.1 -n 255.255.255.0 -g 192.68.0.254 -m 00:00:00:00:00:00 --trace" )
    end

    Then 'I get backtrace' do
      @error_message.should match( /^\s+from/ )
    end
  end
end


def expected_help_message
  %(
Node name and Installer name are mandatory

usage: node add <node-name> --installer <installer-name> -a <IP address> -n <netmask> -g <gateway> --mac <MAC address>

    -i, --installer installer name   The installer name for the installation
    -a, --address address            IP address
    -n, --netmask address            Netmask address
    -g, --gateway address            Gateway address
    -m, --mac MAC address            The MAC address of the NIC (eg. 00:E0:81:05:D3:8B)

    -w, --wol                        Remote power-on using wake on LAN

    -t, --trace                      Print out exception stack traces
    -h, --help                       Show this help message.
  )
end


def output_with command
  Open3.popen3( command + ' 2>&1' ) do | stdin, stdout, stderr |
    return stdout.read
  end
end
