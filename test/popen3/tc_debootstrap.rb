#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


$LOAD_PATH.unshift( '../../lib' ) if __FILE__ =~ /\.rb$/


require 'rubygems'
require 'flexmock'
require 'popen3/debootstrap'
require 'test/unit'


class TC_Debootstrap < Test::Unit::TestCase
  include FlexMock::TestCase
  include Debootstrap


  def teardown
    Popen3::Debootstrap.load_shell Popen3::Shell
  end


  def test_version
    shell_class_mock = flexmock( 'SHELL_CLASS_MOCK' )
    shell_class_mock.should_receive( :open ).with( Proc ).once.and_return do | block |
      shell = flexmock( 'SHELL' )
      shell.should_receive( :on_stdout ).with( Proc ).once.ordered.and_return do | stdout_block |
        stdout_block.call 'ii  debootstrap    0.2.45-0.2     Bootstrap a basic Debian system'
      end
      shell.should_receive( :exec ).with( { 'LC_ALL' => 'C' }, 'dpkg', '-l' ).once.ordered
      block.call shell
    end

    Popen3::Debootstrap.load_shell shell_class_mock

    assert_match( /[\d\.\-]+/, Popen3::Debootstrap.VERSION )
  end


  def test_new
    shell_class_mock = flexmock( 'SHELL_CLASS_MOCK' )
    shell_class_mock.should_receive( :open ).with( Proc ).once.ordered.and_return do | block |
      shell = shell_mock
      block.call shell
      shell
    end

    logger_mock = flexmock( 'LOGGER_MOCK' )
    logger_mock.should_receive( :debug ).with( /\ASTDOUT_LINE\d\Z/ ).times( 3 )
    logger_mock.should_receive( :error ).with( /\ASTDERR_LINE\d\Z/ ).times( 3 )

    Popen3::Debootstrap.load_shell shell_class_mock

    debootstrap = Popen3::Debootstrap.new do | option |
      option.logger = logger_mock
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
    shell_class_mock = flexmock( 'SHELL_CLASS_MOCK' )
    shell_class_mock.should_receive( :open ).with( Proc ).once.ordered.and_return do | block |
      shell = shell_mock
      block.call shell
      shell
    end

    Popen3::Debootstrap.load_shell shell_class_mock

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


  def shell_mock
    return flexmock( 'SHELL' ) do | mock |
      # tochild thread
      mock.should_receive( :puts ).at_least.once

      # fromchild thread
      mock.should_receive( :on_stdout ).with( Proc ).once.ordered.and_return do | block |
        block.call 'STDOUT_LINE0'
        block.call 'STDOUT_LINE1'
        block.call 'STDOUT_LINE2'
      end

      # childerr thread
      mock.should_receive( :on_stderr ).with( Proc ).once.ordered.and_return do | block |
        block.call 'STDERR_LINE0'
        block.call 'STDERR_LINE1'
        block.call 'STDERR_LINE2'
      end

      mock.should_receive( :on_failure ).with( Proc ).once.ordered.and_return do | block |
        assert_raises( RuntimeError ) do
          block.call
        end
      end

      mock.should_receive( :exec ).with( { 'TEST_ENV_NAME' => 'TEST_ENV_VALUE' }, *debootstrap_commandline ).once.ordered

      mock.should_receive( :child_status ).once.ordered.and_return( 'CHILD_STATUS' )
    end
  end


  def debootstrap_commandline
    return [ "/usr/sbin/debootstrap", "--exclude=DHCP-CLIENT,INFO", "--include=INCLUDE", "WOODY", "/TMP", 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/' ]
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
