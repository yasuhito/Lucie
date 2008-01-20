require 'stories/helper'


Story "Disable a node with 'node' command",
%(As a cluster administrator
  I want to disable a node using 'node' command
  So that I can disable a node) do


  # o lucied is [up] / down
  # o node is [added] / not added

  Scenario 'node disable success' do
    Given 'lucied is started' do
      restart_lucied
    end

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
      @stdout, @stderr = output_with( command )
    end

    Then 'It should succeeed with no error message' do
      @stderr.should == ''
    end

    Then 'Installer file should be removed' do
      FileTest.exists?( @installer_file ).should_not be_true
    end
  end


  # o lucied is [up] / down
  # o node is added / [not added]

  Scenario 'node disable success' do
    Given 'lucied is started'
    Given 'all nodes are cleaned'

    When 'I run', './node disable TEST_NODE'

    Then 'It should fail and the error message should be', 'FAILED: Node TEST_NODE not found!' do | expected |
      @stderr.chomp.should == expected
    end
  end


  # o lucied is up / [down]
  # o node is [added] / not added

  Scenario 'node disable success' do
    Given 'lucied is stopped' do
      stop_lucied
    end
    Given 'all nodes are cleaned'
    Given 'TEST_NODE is then added'

    When 'I run', './node disable TEST_NODE'

    Then 'It should fail and the error message should be', 'FAILED: Lucie daemon (lucied) is down.' do | expected |
      @stderr.chomp.should == expected
    end
  end
end


Story 'Trace node disable command',
%(As a cluster administrator
  I can trace a failed 'node disable' command
  So that I can report detailed backtrace to Lucie developers) do

  Scenario 'run node disable with --trace option' do
    When 'I run a command that fails with --trace option' do
      @stdout, @stderr = output_with( "./node disable NO_SUCH_NODE --trace" )
    end

    Then 'I get backtrace' do
      @stderr.should match( /from/ )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
