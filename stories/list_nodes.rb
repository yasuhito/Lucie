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
