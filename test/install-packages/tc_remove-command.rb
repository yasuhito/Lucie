#!/usr/bin/env ruby
#
# $Id: tc_remove-command.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2


$LOAD_PATH.unshift( '../../lib' ) if __FILE__ =~ /\.rb$/


require 'rubygems'
require 'flexmock'
require 'install-packages/command/remove'
require 'test/unit'


class TC_RemoveCommand < Test::Unit::TestCase
  include FlexMock::TestCase


  def test_respond_to_execute
    assert_respond_to InstallPackages::RemoveCommand.new( 'APTGET_MOCK' ), :execute
  end


  def test_execute
    aptget_mock = flexmock( 'APTGET_MOCK' )
    aptget_mock.should_receive( :remove ).with( false ).once

    assert_nothing_raised do
      InstallPackages::RemoveCommand.new( aptget_mock ).execute
    end
  end


  def test_execute_dryrun
    aptget_mock = flexmock( 'APTGET_MOCK' )
    aptget_mock.should_receive( :remove ).with( true ).once

    assert_nothing_raised do
      InstallPackages::RemoveCommand.new( aptget_mock ).execute( true )
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End: