#!/usr/bin/env ruby
#
# $Id: tc_aptget.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2


$LOAD_PATH.unshift( '../../lib' ) if __FILE__ =~ /\.rb$/


require 'rubygems'
require 'flexmock'
require 'install-packages/aptget'
require 'test/unit'


class TC_AptGet < Test::Unit::TestCase
  include FlexMock::TestCase


  def test_clean
    flexstub( Popen3::Shell, 'SHELL_CLASS_MOCK' ).should_receive( :new ).once.and_return do
      shell = flexmock( 'SHELL_MOCK' )
      shell.should_receive( :exec ).with( env, chroot_command + [ 'apt-get', 'clean' ] ).once.ordered
      shell
    end

    assert_nothing_raised do
      InstallPackages::AptGet.new.clean false
    end
  end


  def test_clean_dryrun
    flexstub( STDOUT, 'STDOUT_MOCK' ).should_receive( :puts ).with( " ENV{ ``LC_ALL'' => ``C'' } chroot /tmp/target apt-get clean" ).once

    assert_nothing_raised do
      InstallPackages::AptGet.new.clean true
    end
  end


  def test_install
    flexstub( Popen3::Shell, 'SHELL_CLASS_MOCK' ).should_receive( :new ).once.and_return do
      shell = flexmock( 'SHELL_MOCK' )
      shell.should_receive( :exec ).with( env, chroot_command + 'apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --fix-missing install'.split( ' ' ) + dummy_package ).once.ordered
      shell.should_receive( :exec ).with( env, chroot_command + [ 'apt-get', 'clean' ] ).once.ordered
      shell
    end

    assert_nothing_raised do
      InstallPackages::AptGet.new( dummy_package ).install false
    end
  end


  def test_install_dryrun
    flexstub( STDOUT, 'STDOUT_MOCK' ).should_receive( :puts ).with( %{ ENV{ ``LC_ALL'' => ``C'' } chroot /tmp/target apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --fix-missing install PACKAGE_A PACKAGE_B PACKAGE_C} ).once
    flexstub( STDOUT, 'STDOUT_MOCK' ).should_receive( :puts ).with( " ENV{ ``LC_ALL'' => ``C'' } chroot /tmp/target apt-get clean" ).once

    assert_nothing_raised do
      InstallPackages::AptGet.new( dummy_package ).install true
    end
  end


  def test_remove
    flexstub( Popen3::Shell, 'SHELL_CLASS_MOCK' ).should_receive( :new ).once.and_return do
      shell = flexmock( 'SHELL_MOCK' )
      shell.should_receive( :exec ).with( env, chroot_command + 'apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --purge remove'.split( ' ' ) + dummy_package ).once.ordered
      shell
    end

    assert_nothing_raised do
      InstallPackages::AptGet.new( dummy_package ).remove false
    end
  end


  def test_remove_dryrun
    flexstub( STDOUT, 'STDOUT_MOCK' ).should_receive( :puts ).with( %{ ENV{ ``LC_ALL'' => ``C'' } chroot /tmp/target apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" --purge remove PACKAGE_A PACKAGE_B PACKAGE_C} ).once

    assert_nothing_raised do
      InstallPackages::AptGet.new( dummy_package ).remove true
    end
  end


  private


  def env
    return { 'LC_ALL' => 'C' }
  end


  def chroot_command
    return [ 'chroot', '/tmp/target' ]
  end


  def dummy_package
    return [ 'PACKAGE_A', 'PACKAGE_B', 'PACKAGE_C' ]
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
