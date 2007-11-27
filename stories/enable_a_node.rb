require 'rubygems'

require 'open3'
require 'rbehave'
require 'spec'


Story "Read the 'node enable' help message", %(
  As a cluster administrator
  I want to read help message of 'node enable'
  So that I can understand how to enable a node) do


  Scenario 'node help enable' do
    When 'I run', './node help enable' do | command |
      @help_message = output_with( command ).split
    end

    Then 'the help message should look like', expected_help_message do | message |
      @help_message.should == message.strip.split( /\s+/ )
    end
  end

  Scenario 'node enable --help' do
    When 'I run', './node enable --help'
    Then 'the help message should look like', expected_help_message
  end

  Scenario 'node enable -h' do
    When 'I run', './node enable -h'
    Then 'the help message should look like', expected_help_message
  end
end


Story "Enable a node with 'node' command",
%(As a cluster administrator
  I want to enable a node using 'node' command
  So that I can enable a node) do


  Scenario 'node enable success' do
    # [TODO] インストーラが追加されていない場合、node enable に失敗する
    # シナリオ
    Given 'TEST_INSTALLER installer is added' do
      unless FileTest.directory?( './installers/TEST_INSTALLER' )
        FileUtils.mkdir './installers/TEST_INSTALLER'
      end
    end

    Given 'TEST_NODE is already added and is disabled' do
      unless FileTest.directory?( './nodes/TEST_NODE' )
        FileUtils.mkdir './nodes/TEST_NODE'
      end
      File.open( './nodes/TEST_NODE/00_00_00_00_00_00', 'w' ) do | file |
        file.puts <<-EOF
gateway_address:192.168.0.254
ip_address:192.168.0.1
netmask_address:255.255.255.0
        EOF
      end
    end

    When 'I run', './node enable TEST_NODE --installer TEST_INSTALLER' do | command |
      @error_message = output_with( command )
    end
    
    Then 'It should succeeed with no error message' do
      pending
      @error_message.should be_empty
    end
  end
end


Story 'Trace node add command',
%(As a cluster administrator
  I can trace a failed 'node enable' command
  So that I can report a detailed backtrace to Lucie developers) do

  Scenario 'run node enable with --trace option' do
    Given 'TEST_NODE is already added' do
      unless FileTest.directory?( './nodes/TEST_NODE' )
        FileUtils.mkdir './nodes/TEST_NODE'
      end
    end

    Given 'TEST_INSTALLER is not added yet' do
      if FileTest.directory?( './installers/TEST_INSTALLER' )
        FileUtils.rm_rf './installers/TEST_INSTALLER'
      end
    end

    When 'I run a command that fails with --trace option' do
      @error_message = output_with( './node enable TEST_NODE --installer TEST_INSTALLER --trace' )
    end

    Then 'I get backtrace' do
      pending
      @error_message.should match( /^\s+from/ )
    end
  end
end


def expected_help_message
  %(
Node name and Installer name are mandatory

usage: node enable <node-name> --installer <installer-name>

    -i, --installer installer name   The installer name for the installation
    -t, --trace                      Print out exception stack traces

    -h, --help                       Show this help message.
  )
end


# [FIXME] move to helper methods file
def output_with command
  Open3.popen3( command + ' 2>&1' ) do | stdin, stdout, stderr |
    return stdout.read
  end
end
