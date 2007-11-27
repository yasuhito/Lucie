require 'rubygems'

require 'open3'
require 'rbehave'
require 'spec'


Story "Read the help message", %(
  As a cluster administrator
  I want to read help message of node command
  So that I can understand how to use node command) do


  Scenario 'node help' do
    When 'I run', './node help' do | command |
      @help_message = output_with( command ).split
    end

    Then 'the help message should look like', expected_help_message do | message |
      @help_message.should == message.strip.split( /\s+/ )
    end
  end

  Scenario 'node --help' do
    When 'I run', './node --help'
    Then 'the help message should look like', expected_help_message
  end
end


def expected_help_message
  %(
Usage: node <command> [options] [args]

Lucie node command-line tool, version 0.3.0
Type 'node help <command>' for help on a specific command.
Type 'node --version' to see the version number.

Available commands:
  add        - adds and enables a node
  remove     - removes a node
  enable     - enables installation of a node
  disable    - disables installation of a node
  list       - lists registered nodes

Lucie is an Automatic Cluster Installer.
For additional information, see http://lucie.is.titech.ac.jp/
  )
end


# [FIXME] move to helper methods file.
def output_with command
  Open3.popen3( command + ' 2>&1' ) do | stdin, stdout, stderr |
    return stdout.read
  end
end
