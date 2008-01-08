require 'stories/helper'


Story "list nodes with 'node' command",
%(As a cluster administrator
  I want to get a node list using 'node' command
  So that I can get a node list) do

  Scenario 'node list success' do
    Given 'TEST_NODE is already added and is disabled' do
      add_fresh_node 'TEST_NODE'
      File.open( './nodes/TEST_NODE/00_00_00_00_00_00', 'w' ) do | file |
        file.puts <<-EOF
gateway_address:192.168.0.254
ip_address:192.168.0.1
netmask_address:255.255.255.0
        EOF
      end
    end

    When 'I run', './node list' do | command |
      @stdout, @stderr = output_with( command )
    end

    Then 'the output should look like', /TEST_NODE \(installer = DISABLED\)/ do | regexp |
      @stdout.should match( regexp )
    end
  end
end
