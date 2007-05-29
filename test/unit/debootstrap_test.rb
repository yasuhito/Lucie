#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname( __FILE__ ) + '/../test_helper'

require 'popen3/debootstrap'


class DebootstrapTest < Test::Unit::TestCase
  include Debootstrap


  def test_debootstrap_version
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout ).yields( 'ii  debootstrap    0.2.45-0.2     Bootstrap a basic Debian system' )
    shell_mock.expects( :exec ).with( { 'LC_ALL' => 'C' }, 'dpkg', '-l' )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    assert_equal( '0.2.45-0.2', Popen3::Debootstrap.VERSION )
  end


  def test_debootstrap_new___success___
    shell_mock = mock( 'SHELL', :on_stdout => nil, :on_stderr => nil, :on_failure => nil, :exec => nil, :child_status => 'CHILD_STATUS' )
    Popen3::Shell.expects( :open ).yields( shell_mock ).returns( shell_mock )

    debootstrap = Popen3::Debootstrap.new do | option |
      option.env = { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }
      option.exclude = [ 'DHCP-CLIENT', 'INFO' ]
      option.suite = 'WOODY'
      option.target = '/TMP'
      option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      option.include = [ 'INCLUDE' ]
    end

    assert_equal 'CHILD_STATUS', debootstrap.child_status
  end


  def test_abbreviation___success___
    shell_mock = mock( 'SHELL', :on_stdout => nil, :on_stderr => nil, :on_failure => nil, :exec => nil, :child_status => 'CHILD_STATUS' )
    Popen3::Shell.expects( :open ).yields( shell_mock ).returns( shell_mock )

    debootstrap = debootstrap do | option |
      option.env = { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }
      option.exclude = [ 'DHCP-CLIENT', 'INFO' ]
      option.suite = 'WOODY'
      option.target = '/TMP'
      option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      option.include = [ 'INCLUDE' ]
    end

    assert_equal 'CHILD_STATUS', debootstrap.child_status
  end


  def test_on_stdout_called
    shell_mock = mock( 'SHELL', :on_stderr => nil, :on_failure => nil, :exec => nil )
    shell_mock.expects( :on_stdout ).yields( 'STDOUT' )
    Lucie::Log.expects( :debug ).with( 'STDOUT' ).times( 1 )
    Popen3::Shell.expects( :open ).yields( shell_mock ).returns( shell_mock )

    debootstrap = Popen3::Debootstrap.new do | option |
      option.env = { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }
      option.exclude = [ 'DHCP-CLIENT', 'INFO' ]
      option.suite = 'WOODY'
      option.target = '/TMP'
      option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      option.include = [ 'INCLUDE' ]
    end
  end


  def test_on_stderr_called
    shell_mock = mock( 'SHELL', :on_stdout => nil, :on_failure => nil, :exec => nil )
    shell_mock.expects( :on_stderr ).yields( 'STDERR' )
    Lucie::Log.expects( :error ).with( 'STDERR' ).times( 1 )
    Popen3::Shell.expects( :open ).yields( shell_mock ).returns( shell_mock )

    debootstrap = Popen3::Debootstrap.new do | option |
      option.env = { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }
      option.exclude = [ 'DHCP-CLIENT', 'INFO' ]
      option.suite = 'WOODY'
      option.target = '/TMP'
      option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      option.include = [ 'INCLUDE' ]
    end
  end


  def test_on_stderr_should_raises_runtime_error
    shell_mock = mock( 'SHELL', :on_stdout => nil )
    shell_mock.expects( :on_stderr ).yields( 'ln: ??? File exists' )
    Popen3::Shell.expects( :open ).yields( shell_mock ).returns( shell_mock )

    assert_raises( 'ln: ??? File exists' ) do
      debootstrap = Popen3::Debootstrap.new do | option |
      end
    end
  end


  def test_on_failure_should_raises_runtime_error
    shell_mock = mock( 'SHELL', :on_stdout => nil )
    shell_mock.expects( :on_stderr ).yields( 'STDERR' )
    shell_mock.expects( :on_failure ).yields
    Lucie::Log.expects( :error ).with( 'STDERR' ).times( 1 )
    Popen3::Shell.expects( :open ).yields( shell_mock ).returns( shell_mock )

    assert_raises( 'STDERR' ) do
      debootstrap = Popen3::Debootstrap.new do | option |
        option.env = { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }
        option.exclude = [ 'DHCP-CLIENT', 'INFO' ]
        option.suite = 'WOODY'
        option.target = '/TMP'
        option.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
        option.include = [ 'INCLUDE' ]
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
