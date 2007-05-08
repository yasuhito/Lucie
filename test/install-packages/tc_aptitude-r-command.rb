#!/usr/bin/env ruby
#
# $Id: tc_aptitude-r-command.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2


$LOAD_PATH.unshift( '../../lib' ) if __FILE__ =~ /\.rb$/


require 'rubygems'
require 'flexmock'
require 'install-packages/command/aptitude-r'
require 'test/unit'


class TC_AptitudeRCommand < Test::Unit::TestCase
  include FlexMock::TestCase


  def test_respond_to_execute
    assert_respond_to InstallPackages::AptitudeRCommand.new( 'APTITUDE_MOCK' ), :execute
  end


  def test_execute
    aptitude_mock = flexmock( 'APTITUDE_MOCK' )
    aptitude_mock.should_receive( :install_with_recommends ).with( false ).once

    assert_nothing_raised do
      InstallPackages::AptitudeRCommand.new( aptitude_mock ).execute
    end
  end


  def test_execute_dryrun
    aptitude_mock = flexmock( 'APTITUDE_MOCK' )
    aptitude_mock.should_receive( :install_with_recommends ).with( true ).once

    assert_nothing_raised do
      InstallPackages::AptitudeRCommand.new( aptitude_mock ).execute( true )
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
