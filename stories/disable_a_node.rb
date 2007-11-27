require 'rubygems'

require 'open3'
require 'rbehave'
require 'spec'


Story "Read the 'node disable' help message", %(
  As a cluster administrator
  I want to read help message of 'node disable'
  So that I can understand how to disable a node) do


  Scenario 'node help disable' do
    When 'I run', './node help disable' do | command |
      @help_message = output_with( command ).split
    end

    Then 'the help message should look like', expected_help_message do | message |
      @help_message.should == message.strip.split( /\s+/ )
    end
  end

  Scenario 'node disable --help' do
    When 'I run', './node disable --help'
    Then 'the help message should look like', expected_help_message
  end

  Scenario 'node disable -h' do
    When 'I run', './node disable -h'
    Then 'the help message should look like', expected_help_message
  end
end


Story "Disable a node with 'node' command",
%(As a cluster administrator
  I want to disable a node using 'node' command
  So that I can disable a node) do


  Scenario 'node disable success' do
    Given 'TEST_NODE is already added' do
      @installer_file = './nodes/TEST_NODE/TEST_INSTALLER'

      unless FileTest.directory?( './nodes/TEST_NODE' )
        FileUtils.mkdir './nodes/TEST_NODE'
      end
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


def expected_help_message
  %(
usage: node disable <node-name>

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
