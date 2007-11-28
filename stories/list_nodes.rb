Story "list nodes with 'node' command",
%(As a cluster administrator
  I want to get a nodes list using 'node' command
  So that I can get a nodes list) do


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
      @message = output_with( command ).split( /\s+/ )
    end

    Then 'the output should look like', %(
Nodes directory = '/cygdrive/d/01projects/lucie/nodes'
 TEST_NODE (installer = DISABLED)
) do | message |
      @message.should == message.strip.split( /\s+/ )
    end
  end
end


Story 'Trace node enable command',
%(As a cluster administrator
  I can trace a failed 'node enable' command
  So that I can report a detailed backtrace to Lucie developers) do

  Scenario 'run node enable with --trace option' do
    When 'I run a command that fails with --trace option' do
      pending
      @error_message = output_with( './node list --trace' )
    end

    Then 'I get backtrace' do
      @error_message.should match( /^\s+from/ )
    end
  end
end
