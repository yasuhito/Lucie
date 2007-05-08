#!/usr/bin/env ruby
#
# $Id: tc_kernel.rb 1127 2007-04-09 08:05:12Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1127 $
# License::  GPL2


$LOAD_PATH.unshift( '../../lib' ) if __FILE__ =~ /\.rb$/


require 'rubygems'
require 'flexmock'

require 'install-packages/kernel'
require 'test/unit'


class TC_Kernel < Test::Unit::TestCase
  include FlexMock::TestCase


  def setup
    invoker_mock = flexmock( 'INVOKER_MOCK' )
    invoker_mock.should_receive( :add_command ).with( FlexMock ).times( 5 )
    InstallPackages::App.instance.invoker = invoker_mock
  end


  def teardown
    InstallPackages::App.reset
    InstallPackages::App.instance.invoker = nil
  end


  def test_aptget_install
    setup_aptget_receiver_mock dummy_package
    setup_command_mock :aptget_install

    aptget_install( *dummy_package )
  end


  def test_aptget_remove
    setup_aptget_receiver_mock dummy_package
    setup_command_mock :aptget_remove

    aptget_remove( *dummy_package )
  end


  def test_aptget_clean
    setup_aptget_receiver_mock nil
    setup_command_mock :aptget_clean

    aptget_clean
  end


  def test_aptitude
    setup_aptitude_receiver_mock
    setup_command_mock :aptitude

    aptitude( *dummy_package )
  end


  def test_aptitude_r
    setup_aptitude_receiver_mock
    setup_command_mock :aptitude_r

    aptitude_r( *dummy_package )
  end


  private


  def setup_aptget_receiver_mock package
    aptget_class_mock = flexmock( 'APTGET_CLASS_MOCK' )
    aptget_class_mock.should_receive( :new ).with( package ).once.and_return( receiver_mock )

    InstallPackages::App.load_aptget aptget_class_mock
  end


  def setup_aptitude_receiver_mock
    aptitude_class_mock = flexmock( 'APTITUDE_CLASS_MOCK' )
    aptitude_class_mock.should_receive( :new ).with( dummy_package ).once.and_return( receiver_mock )

    InstallPackages::App.load_aptitude aptitude_class_mock
  end


  def setup_command_mock commandType
    command_class_mock = flexmock( 'COMMAND_CLASS_MOCK' )
    command_class_mock.should_receive( :new ).with( receiver_mock ).once.and_return do
      command_mock = flexmock( 'COMMAND_MOCK' )
      command_mock.should_receive( :respond_to? ).with( :execute ).once.and_return( true )
      command_mock
    end

    InstallPackages::App.load_command( commandType => command_class_mock )
  end


  def receiver_mock
    return 'RECEIVER_MOCK'
  end


  def dummy_package
    return [ 'FOO', 'BAR', 'BAZ' ]
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
