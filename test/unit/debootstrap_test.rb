#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname( __FILE__ ) + '/../test_helper'

require 'lib/popen3/debootstrap'


class TC_Debootstrap < Test::Unit::TestCase
  include Debootstrap


  def test_version
    shell_mock = mock( 'SHELL' )
    shell_mock.expects( :on_stdout ).yields( 'ii  debootstrap    0.2.45-0.2     Bootstrap a basic Debian system' )
    shell_mock.expects( :exec ).with( { 'LC_ALL' => 'C' }, 'dpkg', '-l' )
    Popen3::Shell.expects( :open ).yields( shell_mock )

    assert_match( /[\d\.\-]+/, Popen3::Debootstrap.VERSION )
  end


  def test_new
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


  def test_abbreviation
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
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
