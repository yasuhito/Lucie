#!/usr/bin/env ruby
#
# $Id: tc_app.rb 1127 2007-04-09 08:05:12Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1127 $
# License::  GPL2


$LOAD_PATH.unshift( '../../lib' ) if __FILE__ =~ /\.rb$/


require 'rubygems'
require 'flexmock'
require 'install-packages/app'
require 'test/unit'


class TC_App < Test::Unit::TestCase
  include FlexMock::TestCase


  def setup
    InstallPackages::App.instance.invoker = nil
  end


  def teardown
    InstallPackages::App.instance.invoker = nil
  end


  def test_exit_version_option
    option = flexmock( 'OPTION_MOCK' )
    option.should_receive( :version ).once.ordered.and_return( true )

    assert_raises( SystemExit ) do
      InstallPackages::App.instance.main option
    end
  end


  def test_exit_help_option
    option = flexmock( 'OPTION_MOCK' )
    option.should_receive( :version ).once.ordered.and_return( nil )
    option.should_receive( :help ).once.ordered.and_return( true )

    assert_raises( SystemExit ) do
      InstallPackages::App.instance.main option
    end
  end


  def test_install_command
    option = option_mock( 'install' )

    app = InstallPackages::App.instance
    app.invoker = invoker_mock( InstallPackages::InstallCommand, option )
    assert_nothing_raised do
      app.main option
    end
  end


  def test_remove_comand
    option = option_mock( 'remove' )

    app = InstallPackages::App.instance
    app.invoker = invoker_mock( InstallPackages::RemoveCommand, option )
    assert_nothing_raised do
      app.main option
    end
  end


  def test_clean_comand
    option = option_mock( 'clean' )

    app = InstallPackages::App.instance
    app.invoker = invoker_mock( InstallPackages::CleanCommand, option )
    assert_nothing_raised do
      app.main option
    end
  end


  def test_aptitude_command
    option = option_mock( 'aptitude' )

    app = InstallPackages::App.instance
    app.invoker = invoker_mock( InstallPackages::AptitudeCommand, option )
    assert_nothing_raised do
      app.main option
    end
  end


  def test_aptitude_r_command
    option = option_mock( 'aptitude-r' )

    app = InstallPackages::App.instance
    app.invoker = invoker_mock( InstallPackages::AptitudeRCommand, option )
    assert_nothing_raised do
      app.main option
    end
  end


  private


  def invoker_mock commandClass, option
    invoker_mock = flexmock( 'INVOKER' )
    invoker_mock.should_receive( :add_command ).with( commandClass ).once.ordered
    invoker_mock.should_receive( :start ).with( option ).once.ordered
    return invoker_mock
  end


  def option_mock command
    option = flexmock( 'OPTION_MOCK' )
    option.should_receive( :version ).once.ordered.and_return( nil )
    option.should_receive( :help ).once.ordered.and_return( nil )
    fixture = File.join( File.dirname( __FILE__ ), "fixtures/install-packages.#{ command }.conf" )
    option.should_receive( :config_file ).twice.ordered.and_return( fixture )

    return option
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
