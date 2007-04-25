#!/usr/bin/env ruby
#
# $Id$
#
# Author::   Yasuhito Takamiya (mailto:takamiya@matsulab.is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2


$LOAD_PATH.unshift( '../../lib' ) if __FILE__ =~ /\.rb$/


require 'rubygems'
require 'flexmock'

require 'lucie/nfsroot-task'
require 'rake'
require 'rake/classic_namespace'
require 'test/unit'


class TC_NfsrootTask < Test::Unit::TestCase
  include FlexMock::TestCase


  def setup
    Task.clear
    Rake::NfsrootTask.reset
  end


  def teardown
    Task.clear
    Rake::NfsrootTask.reset
  end


  def test_clobber_nfsroot_task
    shell_mock = flexmock( 'SHELL' )
    shell_mock.should_receive( :logger= ).with( Lucie ).once.ordered
    shell_mock.should_receive( :open ).with( Proc ).at_least.once.ordered
    shell_mock.should_receive( :new ).with( Proc ).once.ordered
    Rake::NfsrootTask.load_shell shell_mock

    Rake::NfsrootTask.new do | task |
      task.name = 'NFSROOT'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.target_directory = '/TMP/NFSROOT'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.extra_packages = [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ]
      task.kernel_package = 'KERNEL.DEB'
      task.root_password = 'XXXXXXXX'
    end

    Task[ :clobber_NFSROOT ].execute
  end


  def test_nfsroot_task
    shell_mock = flexmock( 'SHELL' )
    shell_mock.should_receive( :logger= ).with( Lucie ).once
    shell_mock.should_receive( :open ).with( Proc ).at_least.once.and_return( 'DUMMY_RETURN_VALUE' )
    Rake::NfsrootTask.load_shell shell_mock

    aptget_mock = flexmock( 'APTGET' )
    aptget_mock.should_receive( :apt ).at_least.once
    aptget_mock.should_receive( :check ).at_least.once
    aptget_mock.should_receive( :clean ).at_least.once
    aptget_mock.should_receive( :update ).at_least.once
    Rake::NfsrootTask.load_aptget aptget_mock

    file_mock = flexmock( 'FILE' )
    file_mock.should_receive( :open ).at_least.once
    Rake::NfsrootTask.load_file file_mock

    Rake::NfsrootTask.new do | task |
      task.name = 'NFSROOT'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.target_directory = '/TMP/NFSROOT'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.extra_packages = [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ]
      task.kernel_package = 'KERNEL.DEB'
      task.root_password = 'XXXXXXXX'
    end

    Task[ :NFSROOT ].execute
  end


  def test_accessor
    nfsroot_task = Rake::NfsrootTask.new do | task |
      task.name = 'NFSROOT'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.target_directory = '/TMP/NFSROOT'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.extra_packages = [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ]
      task.kernel_package = 'KERNEL.DEB'
      task.root_password = 'XXXXXXXX'
      task.http_proxy = 'HTTP://PROXY/'
    end

    assert_equal 'NFSROOT', nfsroot_task.name
    assert_equal 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/', nfsroot_task.mirror
    assert_equal '/TMP/NFSROOT', nfsroot_task.target_directory
    assert_equal 'DEBIAN', nfsroot_task.distribution
    assert_equal 'SARGE', nfsroot_task.suite
    assert_equal [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ], nfsroot_task.extra_packages
    assert_equal 'KERNEL.DEB', nfsroot_task.kernel_package
    assert_equal 'XXXXXXXX', nfsroot_task.root_password
    assert_equal 'HTTP://PROXY/', nfsroot_task.http_proxy
  end


  def test_all_targets_defined
    Rake::NfsrootTask.new do | task |
      task.name = 'NFSROOT'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.target_directory = '/TMP/NFSROOT'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.extra_packages = [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ]
      task.kernel_package = 'KERNEL.DEB'
      task.root_password = 'XXXXXXXX'
    end

    assert_kind_of Rake::Task, Task[ 'NFSROOT' ]
    assert_kind_of Rake::Task, Task[ 'reNFSROOT' ]
    assert_kind_of Rake::Task, Task[ 'clobber_NFSROOT' ]
    assert_kind_of Rake::Task, Task[ '/TMP/NFSROOT' ]
    assert_kind_of Rake::Task, Task[ :installer_base ]
    assert_kind_of Rake::Task, Task[ :reinstaller_base ]
    assert_kind_of Rake::Task, Task[ '/var/lib/lucie/installer_base/DEBIAN_SARGE.tgz' ]
  end
end

### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
