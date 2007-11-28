Story "Disable a node with 'node' command",
%(As a cluster administrator
  I want to disable a node using 'node' command
  So that I can disable a node) do

  Scenario 'node disable success' do
    Given 'all nodes are cleaned' do
      cleanup_nodes
    end

    Given 'TEST_NODE is then added' do
      @installer_file = './nodes/TEST_NODE/TEST_INSTALLER'

      add_fresh_node 'TEST_NODE'
      FileUtils.touch @installer_file
      File.open( './nodes/TEST_NODE/00_00_00_00_00_00', 'w' ) do | file |
        file.puts <<-EOF
gateway_address:192.168.0.254
ip_address:192.168.0.1
netmask_address:255.255.255.0
        EOF
      end
    end

    When 'I run', './node disable TEST_NODE' do | command |
      @error_message = output_with( command )
    end

    Then 'It should succeeed with no error message' do
      @error_message.should be_empty
    end

    Then 'Installer file should be removed' do
      FileTest.exists?( @installer_file ).should_not be_true
    end
  end
end


Story 'Trace node disable command',
%(As a cluster administrator
  I can trace a failed 'node disable' command
  So that I can report detailed backtrace to Lucie developers) do

  Scenario 'run node disable with --trace option' do
    When 'I run a command that fails with --trace option' do
      @error_message = output_with( "./node disable NO_SUCH_NODE --trace" )
    end

    Then 'I get backtrace' do
      @error_message.should match( /^\s+from/ )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
