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


def expected_help_message
  %(
usage: node disable <node-name>

    -t, --trace                      Print out exception stack traces

    -h, --help                       Show this help message.
  )
end


def output_with command
  Open3.popen3( command + ' 2>&1' ) do | stdin, stdout, stderr |
    return stdout.read
  end
end
