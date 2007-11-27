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


def expected_help_message
  %(
Node name and Installer name are mandatory

usage: node enable <node-name> --installer <installer-name> -a <IP address> -n <netmask> -g <gateway>

    -i, --installer installer name   The installer name for the installation
    -w, --wol                        Remote power-on using wake on LAN
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
