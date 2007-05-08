#!/usr/bin/env ruby
#
# $Id: tc_command.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2


$LOAD_PATH.unshift( '../../lib' ) if __FILE__ =~ /\.rb$/


require 'rubygems'
require 'flexmock'
require 'install-packages/command'
require 'test/unit'


class TC_Command < Test::Unit::TestCase
  class DummyClass
    include InstallPackages::Command
  end


  def test_not_implemented_error
    assert_raises( NotImplementedError ) do
      DummyClass.new.execute
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
