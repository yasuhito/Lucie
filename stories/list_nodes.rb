require 'rubygems'

require 'open3'
require 'rbehave'
require 'spec'


Story "Read the 'node list' help message", %(
  As a cluster administrator
  I want to read help message of 'node list'
  So that I can understand how to get nodes list) do

  Scenario 'node help list' do
    When 'I run', './node help list' do | command |
      @help_message = output_with( command ).split
    end

    Then 'the help message should look like', expected_help_message do | message |
      @help_message.should == message.strip.split( /\s+/ )
    end
  end

  Scenario 'node list --help' do
    When 'I run', './node list --help'
    Then 'the help message should look like', expected_help_message
  end

  Scenario 'node list -h' do
    When 'I run', './node list -h'
    Then 'the help message should look like', expected_help_message
  end
end


Story "list nodes with 'node' command",
%(As a cluster administrator
  I want to get a nodes list using 'node' command
  So that I can get a nodes list) do


  Scenario 'node list success' do
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


def expected_help_message
  %(
usage: node list

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
