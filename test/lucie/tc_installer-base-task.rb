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
require 'rake'
require 'lucie/installer-base-task'
require 'test/unit'


class TC_InstallerBaseTask < Test::Unit::TestCase
  include FlexMock::TestCase


  def setup
    Task.clear
  end


  def teardown
    Task.clear
    Rake::InstallerBaseTask.reset
  end


  def test_accessor
    installer_base_task = Rake::InstallerBaseTask.new do | task |
      task.target_directory = '/TMP'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.include = [ 'INCLUDE' ]
    end
    assert_equal :installer_base, installer_base_task.name
    assert_equal '/TMP', installer_base_task.target_directory
    assert_equal 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/', installer_base_task.mirror
    assert_equal 'DEBIAN', installer_base_task.distribution
    assert_equal 'SARGE', installer_base_task.suite
    assert_equal [ 'INCLUDE' ], installer_base_task.include
  end


  def test_all_targets_defined
    Rake::InstallerBaseTask.new do | task |
      task.target_directory = '/TMP'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
    end

    assert_kind_of Rake::Task, Task[ :installer_base ]
    assert_kind_of Rake::Task, Task[ :reinstaller_base ]
    assert_kind_of Rake::Task, Task[ '/TMP/DEBIAN_SARGE.tgz' ]

    assert_equal( "Build installer base tarball for DEBIAN distribution, version = ``SARGE''.", Task[ :installer_base ].comment )
    assert_equal( "Force a rebuild of the installer base tarball.", Task[ :reinstaller_base ].comment )
  end


  def test_installer_base_target_prerequisites
    Rake::InstallerBaseTask.new do | task |
      task.target_directory = '/TMP/'
      task.distribution = 'DEBIAN'
      task.suite = 'WOODY'
    end
    assert_equal [ '/TMP/DEBIAN_WOODY.tgz' ], Task[ :installer_base ].prerequisites
  end


  def test_reinstaller_base_target_prerequisites
    Rake::InstallerBaseTask.new do | task |
      task.distribution = 'DEBIAN'
      task.suite = 'WOODY'
    end
    assert_equal [ "clobber_installer_base", "installer_base" ], Task[ :reinstaller_base ].prerequisites
  end


  def test_clobber_target
    shell_mock = flexmock( 'SHELL' )
    # shell_mock.should_receive( :logger= ).with( FlexMock ).once.ordered
    shell_mock.should_receive( :open ).with( Proc ).once
    Rake::InstallerBaseTask.load_shell shell_mock

    Rake::InstallerBaseTask.new do | task |
      task.logger = nil
      task.target_directory = '/TMP'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.include = [ 'INCLUDE' ]
    end
    Task[ :clobber_installer_base ].execute
  end


  def test_installer_base_target
    logger_mock = flexmock( 'LOGGER' )
    logger_mock.should_receive( :info ).with( String ).at_least.once
    logger_mock.should_receive( :debug ).with( String ).at_least.once
    logger_mock.should_receive( :error ).with( String ).at_least.once

    shell_mock = flexmock( 'SHELL' )
    shell_mock.should_receive( :logger= ).with( FlexMock ).once.ordered
    shell_mock.should_receive( :open ).with( Proc ).times( 2 ).ordered
    Rake::InstallerBaseTask.load_shell shell_mock

    debootstrap_mock = flexmock( 'DEBOOTSTRAP' )
    debootstrap_mock.should_receive( :VERSION ).once.ordered
    debootstrap_mock.should_receive( :new ).with( Proc ).once.ordered.and_return do | block |
      option_mock = flexmock( 'DEBOOTSTRAP_OPTION' )
      option_mock.should_receive( :logger= ).with( logger_mock ).once.ordered
      option_mock.should_receive( :env= ).with( { 'LC_ALL' => 'C', 'http_proxy' => nil } ).once.ordered
      option_mock.should_receive( :exclude= ).with( [ 'dhcp-client', 'info' ] ).once.ordered
      option_mock.should_receive( :suite= ).with( 'SARGE' ).once.ordered
      option_mock.should_receive( :target= ).with( '/TMP' ).once.ordered
      option_mock.should_receive( :mirror= ).with( 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/' ).once.ordered
      option_mock.should_receive( :include= ).with( [ 'INCLUDE' ] ).once.ordered
      block.call option_mock
    end
    Rake::InstallerBaseTask.load_debootstrap debootstrap_mock

    aptget_mock = flexmock( 'APTGET' )
    aptget_mock.should_receive( :clean ).with( { :root => '/TMP', :logger => logger_mock } ).once
    Rake::InstallerBaseTask.load_aptget aptget_mock

    Rake::InstallerBaseTask.new do | task |
      task.logger = logger_mock
      task.target_directory = '/TMP'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.include = [ 'INCLUDE' ]
    end
    Task[ '/TMP/DEBIAN_SARGE.tgz' ].execute
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
