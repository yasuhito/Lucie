require 'stories/helper'


Story 'Read the help message', %(
  As a cluster administrator
  I want to read help message of node command
  So that I can understand how to use node command) do

  Scenario 'node help' do
    When 'I run', './node help' do | command |
      @help_message, @stderr = output_with( command )
    end

    Then 'the help message should look like', expected_help_message[ :node_help ] do | message |
      @help_message.split.should == message.strip.split( /\s+/ )
    end
  end

  Scenario 'node --help' do
    When 'I run', './node --help'
    Then 'the help message should look like', expected_help_message[ :node_help ]
  end
end


Story "Read the 'node add' help message", %(
  As a cluster administrator
  I want to read help message of 'node add' command
  So that I can understand how to add a node to the system) do

  Scenario 'node help add' do
    When 'I run', './node help add'
    Then 'the help message should look like', expected_help_message[ :node_add ]
  end

  Scenario 'node add --help' do
    When 'I run', './node add --help'
    Then 'the help message should look like', expected_help_message[ :node_add ]
  end

  Scenario 'node add -h' do
    When 'I run', './node add -h'
    Then 'the help message should look like', expected_help_message[ :node_add ]
  end
end


Story "Read the 'node remove' help message", %(
  As a cluster administrator
  I want to read help message of 'node remove' command
  So that I can understand how to remove a node from the system) do

  Scenario 'node help remove' do
    When 'I run', './node help remove'
    Then 'the help message should look like', expected_help_message[ :node_remove ]
  end

  Scenario 'node remove --help' do
    When 'I run', './node remove --help'
    Then 'the help message should look like', expected_help_message[ :node_remove ]
  end

  Scenario 'node remove -h' do
    When 'I run', './node remove -h'
    Then 'the help message should look like', expected_help_message[ :node_remove ]
  end
end


Story "Read the 'node enable' help message", %(
  As a cluster administrator
  I want to read help message of 'node enable'
  So that I can understand how to enable a node) do

  Scenario 'node help enable' do
    When 'I run', './node help enable'
    Then 'the help message should look like', expected_help_message[ :node_enable ]
  end

  Scenario 'node enable --help' do
    When 'I run', './node enable --help'
    Then 'the help message should look like', expected_help_message[ :node_enable ]
  end

  Scenario 'node enable -h' do
    When 'I run', './node enable -h'
    Then 'the help message should look like', expected_help_message[ :node_enable ]
  end
end


Story "Read the 'node disable' help message", %(
  As a cluster administrator
  I want to read help message of 'node disable'
  So that I can understand how to disable a node) do

  Scenario 'node help disable' do
    When 'I run', './node help disable'
    Then 'the help message should look like', expected_help_message[ :node_disable ]
  end

  Scenario 'node disable --help' do
    When 'I run', './node disable --help'
    Then 'the help message should look like', expected_help_message[ :node_disable ]
  end

  Scenario 'node disable -h' do
    When 'I run', './node disable -h'
    Then 'the help message should look like', expected_help_message[ :node_disable ]
  end
end


Story "Read the 'node list' help message", %(
  As a cluster administrator
  I want to read help message of 'node list'
  So that I can understand how to get nodes list) do

  Scenario 'node help list' do
    When 'I run', './node help list'
    Then 'the help message should look like', expected_help_message[ :node_list ]
  end

  Scenario 'node list --help' do
    When 'I run', './node list --help'
    Then 'the help message should look like', expected_help_message[ :node_list ]
  end

  Scenario 'node list -h' do
    When 'I run', './node list -h'
    Then 'the help message should look like', expected_help_message[ :node_list ]
  end
end


Story "Read the 'node install' help message", %(
  As a cluster administrator
  I want to read help message of 'node install'
  So that I can understand how to install a node) do

  Scenario 'node help list' do
    When 'I run', './node help install'
    Then 'the help message should look like', expected_help_message[ :node_install ]
  end

  Scenario 'node list --help' do
    When 'I run', './node install --help'
    Then 'the help message should look like', expected_help_message[ :node_install ]
  end

  Scenario 'node list -h' do
    When 'I run', './node install -h'
    Then 'the help message should look like', expected_help_message[ :node_install ]
  end
end


def expected_help_message
  {
    :node_help => %(
Usage: node <command> [options] [args]

Lucie node command-line tool, version 0.3.0
Type 'node help <command>' for help on a specific command.
Type 'node --version' to see the version number.

Available commands:
  add        - adds and enables a node
  remove     - removes a node
  install    - installs a node

  enable     - enables installation of a node
  disable    - disables installation of a node
  list       - lists registered nodes

Lucie is an Automatic Cluster Installer.
For additional information, see http://lucie.is.titech.ac.jp/
  ),

    :node_add => %(
usage: node add <node-name> --installer <installer-name> -a <IP address> -n <netmask> -g <gateway> --mac <MAC address>

    -i, --installer installer name   The installer name for the installation
    -a, --address address            IP address
    -n, --netmask address            Netmask address
    -g, --gateway address            Gateway address
    -m, --mac MAC address            The MAC address of the NIC (eg. 00:E0:81:05:D3:8B)

    -w, --wol                        Remote power-on using wake on LAN

    -t, --trace                      Print out exception stack traces
    -h, --help                       Show this help message.
  ),

    :node_remove => %(
usage: node remove <node-name>

    -t, --trace                      Print out exception stack traces

    -h, --help                       Show this help message.
  ),

    :node_enable => %(
usage: node enable <node-name> --installer <installer-name>

    -i, --installer installer name   The installer name for the installation
    -n, --no-builder                 Disable installer builder

    -t, --trace                      Print out exception stack traces

    -h, --help                       Show this help message.
  ),

    :node_disable => %(
usage: node disable <node-name>

    -t, --trace                      Print out exception stack traces

    -h, --help                       Show this help message.
  ),

    :node_list => %(
usage: node list

    -t, --trace                      Print out exception stack traces

    -h, --help                       Show this help message.
  ),


    :node_install => %(
usage: node install <node-name>

    -t, --trace                      Print out exception stack traces

    -h, --help                       Show this help message.
  )
 }
end
