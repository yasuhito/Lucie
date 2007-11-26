require 'rubygems'

require 'open3'
require 'rbehave'
require 'spec'


Story "Read the 'node remove' help message", %(
  As a cluster administrator
  I want to read help message of 'node remove'
  So that I can understand how to remove a node from the system) do

  Scenario 'node help remove' do
    When 'I run', './node help remove' do | command |
      @help_message = output_with( command ).split
    end

    Then 'the help message should look like', expected_help_message do | message |
      @help_message.should == message.strip.split( /\s+/ )
    end
  end

  Scenario 'node remove --help' do
    When 'I run', './node remove --help'
    Then 'the help message should look like', expected_help_message
  end

  Scenario 'node remove -h' do
    When 'I run', './node remove -h'
    Then 'the help message should look like', expected_help_message
  end
end


Story "Remove a node with 'node remove' command", %(
  As a cluster administrator
  I want to remove a node using 'node remove' command
  So that I can remove a node from the system) do

  Scenario 'remove a node' do
    Given 'a node named', 'TEST_NODE' do | node_name |
      FileUtils.mkdir File.join( './nodes', node_name )
    end

    When 'I remove the node', 'TEST_NODE' do | node_name |
      system( "./node remove #{ node_name } 2>&1 >/dev/null" )
    end
    
    Then 'the following directory should be removed:', File.join( './nodes', 'TEST_NODE' ) do | node_directory |
      FileTest.exists?( node_directory ).should_not be_true
    end
  end

  Scenario 'node remove fails' do
    When 'I remove non-existing node named', 'NO_SUCH_NODE' do | node_name |
      Open3.popen3( "./node remove #{ node_name } 2>&1 >/dev/null" ) do | stdin, stdout, stderr |
        @error_message = stdout.read.chomp
      end
    end

    Then 'I get error look like:', "FAILED: Node 'NO_SUCH_NODE' not found." do | message |
      @error_message.should == message
    end
  end
end


Story 'Trace node remove command',
%(As a cluster administrator
  I can trace a failed command
  So that I can report detailed backtrace to Lucie developers) do

  Scenario 'run node remove with --trace option' do
    When 'I run a command that fails with --trace option' do
      @error_message = output_with( './node remove NO_SUCH_NODE --trace' )
    end

    Then 'I get backtrace' do
      @error_message.should match( /\(RuntimeError\)/ )
      @error_message.should match( /^\s+from/ )
    end
  end
end


def expected_help_message
  %(
usage: node remove <node-name>

    -t, --trace                      Print out exception stack traces

    -h, --help                       Show this help message.
  )
end


def output_with command
  Open3.popen3( command + ' 2>&1' ) do | stdin, stdout, stderr |
    return stdout.read
  end
end
