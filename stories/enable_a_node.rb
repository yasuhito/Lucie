require 'stories/helper'


Story "Enable a node with 'node' command",
%(As a cluster administrator
  I want to enable a node using 'node' command
  So that I can enable a node) do


  # o lucied is [up] / down
  # o installer is [added] / not added
  # o node is [added] / not added

  Scenario 'node enable success' do
    Given 'lucied is started' do
      restart_lucied
    end

    Given 'No node is added' do
      cleanup_nodes
    end

    Given 'No installer is added' do
      cleanup_installers
    end

    Given 'TEST_INSTALLER installer is added' do
      system "./installer add TEST_INSTALLER --url https://lucie.is.titech.ac.jp/svn/trunk/config/demo --no-builder"
      FileUtils.mkdir( 'installers/TEST_INSTALLER/build-1.1/' )
      FileUtils.touch( 'installers/TEST_INSTALLER/build-1.1/build_status.success.in10s' )
    end

    Given 'TEST_NODE is already added and is disabled' do
      add_fresh_node 'TEST_NODE'
      File.open( './nodes/TEST_NODE/00_00_00_00_00_00', 'w' ) do | file |
        file.puts <<-EOF
gateway_address:192.168.2.254
ip_address:192.168.2.1
netmask_address:255.255.255.0
        EOF
      end
    end

    When 'I run', './node enable TEST_NODE --installer TEST_INSTALLER --no-builder' do | command |
      @stdout, @stderr = output_with( command )
    end

    Then 'It should succeeed with no error message' do
      @stderr.should be_empty
    end
  end


  # o lucied is [up] / down
  # o installer is added / [not added]
  # o node is [added] / not added

  Scenario 'node enable fail if installer is not added' do
    Given 'lucied is started'
    Given 'No node is added'
    Given 'No installer is added'

    Given 'TEST_NODE is already added and is disabled'

    When 'I run', './node enable TEST_NODE --installer TEST_INSTALLER --no-builder'

    Then 'It should fail with', "Installer 'TEST_INSTALLER' is not added yet. Please add installer with 'installer add <installer-name>' first." do | expected |
      @stderr.chomp.should == expected
    end
  end


  # o lucied is [up] / down
  # o installer is [added] / not added
  # o node is added / [not added]

  Scenario 'node enable fail if installer is not added' do
    Given 'lucied is started'
    Given 'No node is added'
    Given 'No installer is added'

    Given 'TEST_INSTALLER installer is added'

    When 'I run', './node enable TEST_NODE --installer TEST_INSTALLER --no-builder'

    Then 'It should fail with', "Node 'TEST_NODE' is not added yet. Please add node with 'node add <node-name>' first." do | expected |
      @stderr.chomp.should == expected
    end
  end


  # o lucied is up / [down]
  # o installer is [added] / not added
  # o node is [added] / not added

  Scenario 'node enable fail if installer is not added' do
    Given 'lucied is stopped' do
      stop_lucied
    end

    Given 'No node is added'
    Given 'No installer is added'

    Given 'TEST_INSTALLER installer is added'

    Given 'TEST_NODE is already added and is disabled'

    When 'I run', './node enable TEST_NODE --installer TEST_INSTALLER --no-builder'

    Then 'It should fail with', 'FAILED: Lucie daemon (lucied) is down.' do | expected |
      @stderr.chomp.should == expected
    end
  end


  Scenario 'node enable fails if installer is not built' do
    Given 'lucied is started'
    Given 'No node is added'
    Given 'No installer is added'

    Given 'TEST_NODE is already added and is disabled'

    Given 'TEST_INSTALLER is added and is not built' do
      add_fresh_installer 'TEST_INSTALLER'
    end

    When 'I run', './node enable TEST_NODE --installer TEST_INSTALLER --no-builder'

    Then 'It should fail with', "FAILED: installer 'TEST_INSTALLER' is not built yet."
  end


  Scenario 'node enable fails if installer is being built' do
    Given 'lucied is started'
    Given 'No node is added'
    Given 'No installer is added'

    Given 'TEST_NODE is already added and is disabled'

    Given 'TEST_INSTALLER is added and is being built' do
      add_fresh_installer 'TEST_INSTALLER'
      FileUtils.mkdir( 'installers/TEST_INSTALLER/build-1.1/' )
      FileUtils.touch( 'installers/TEST_INSTALLER/build-1.1/build_status.incomplete' )
    end

    When 'I run', './node enable TEST_NODE --installer TEST_INSTALLER --no-builder'

    Then 'It should fail with', "FAILED: installer 'TEST_INSTALLER' is being built now."
  end


  Scenario 'node enable fails if installer is broken' do
    Given 'lucied is started'
    Given 'No node is added'
    Given 'No installer is added'

    Given 'TEST_NODE is already added and is disabled'

    Given 'TEST_INSTALLER is added and is broken' do
      add_fresh_installer 'TEST_INSTALLER'
      FileUtils.mkdir( 'installers/TEST_INSTALLER/build-1.1/' )
      FileUtils.touch( 'installers/TEST_INSTALLER/build-1.1/build_status.failed.in10s' )
    end

    When 'I run', './node enable TEST_NODE --installer TEST_INSTALLER --no-builder'

    Then 'It should fail with', "FAILED: installer 'TEST_INSTALLER' is broken."
  end
end


Story 'Trace node enable command',
%(As a cluster administrator
  I can trace a failed 'node enable' command
  So that I can report a detailed backtrace to Lucie developers) do

  Scenario 'run node enable with --trace option' do
    Given 'TEST_NODE is already added' do
      add_fresh_node 'TEST_NODE'
    end

    Given 'TEST_INSTALLER is not added yet' do
      cleanup_installers
    end

    When 'I run a command that fails with --trace option' do
      @stdout, @stderr = output_with( './node enable TEST_NODE --installer TEST_INSTALLER --trace' )
    end

    Then 'I get backtrace' do
      @stderr.should match( /from/ )
    end
  end
end
