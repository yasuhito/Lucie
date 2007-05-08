#!/usr/bin/env ruby
#
# $Id: tc_invoker.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2


$LOAD_PATH.unshift( '../../lib' ) if __FILE__ =~ /\.rb$/


require 'rubygems'
require 'flexmock'
require 'install-packages/invoker'
require 'test/unit'


class TC_Invoker < Test::Unit::TestCase
  include FlexMock::TestCase


  def setup
    @invoker = InstallPackages::Invoker.new
  end


  def test_add_command
    command_a = flexmock( 'COMMAND_MOCK_A' )
    command_a.should_receive( :respond_to? ).with( :execute ).once.ordered.and_return( true )

    @invoker.add_command command_a
    assert_equal 1, @invoker.commands.size
    assert_equal command_a, @invoker.commands[ 0 ]

    command_b = flexmock( 'COMMAND_MOCK_B' )
    command_b.should_receive( :respond_to? ).with( :execute ).once.ordered.and_return( true )

    @invoker.add_command command_b
    assert_equal 2, @invoker.commands.size
    assert_equal command_a, @invoker.commands[ 0 ]
    assert_equal command_b, @invoker.commands[ 1 ]
  end


  def test_start_empty_command
    assert_nothing_raised do
      @invoker.start
    end
  end


  def test_empty_commands
    assert_equal [], @invoker.commands
  end


  def test_start
    command_a = flexmock( 'COMMAND_MOCK_A' )
    command_a.should_receive( :respond_to? ).with( :execute ).once.ordered.and_return( true )
    command_a.should_receive( :execute ).once.ordered

    command_b = flexmock( 'COMMAND_MOCK_B' )
    command_b.should_receive( :respond_to? ).with( :execute ).once.ordered.and_return( true )
    command_b.should_receive( :execute ).once.ordered

    @invoker.add_command command_a
    @invoker.add_command command_b
    @invoker.start
  end


  def test_add_invalid_command
    assert_raises( RuntimeError ) do
      @invoker.add_command nil
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
