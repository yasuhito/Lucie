#!/usr/bin/env ruby
#
# $Id: tc_nfsroot-task.rb 20 2007-05-07 08:15:18Z yasuhito $
#
# Author::   Yasuhito Takamiya (mailto:takamiya@matsulab.is.titech.ac.jp)
# Revision:: $LastChangedRevision: 20 $
# License::  GPL2


require File.dirname( __FILE__ ) + '/../test_helper'


require 'flexmock'
require 'rake'


class NfsrootTest < Test::Unit::TestCase
  include FlexMock::TestCase


  def teardown
    Rake::Task.clear
  end


  def test_accessor
    nfsroot_task = Nfsroot.configure do | task |
      task.distribution = 'DEBIAN'
      task.extra_packages = [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ]
      task.http_proxy = 'HTTP://PROXY/'
      task.kernel_package = 'KERNEL.DEB'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.root_password = 'XXXXXXXX'
      task.sources_list = 'DEB HTTP://MY.SOURCES.LIST/DEBIAN MAIN CONTRIB NON-FREE'
      task.ssh_identity = 'PUBLIC_KEY'
      task.suite = 'SARGE'
    end

    assert_equal 'DEBIAN', nfsroot_task.distribution
    assert_equal [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ], nfsroot_task.extra_packages
    assert_equal 'HTTP://PROXY/', nfsroot_task.http_proxy
    assert_equal 'KERNEL.DEB', nfsroot_task.kernel_package
    assert_equal 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/', nfsroot_task.mirror
    assert_equal 'XXXXXXXX', nfsroot_task.root_password
    assert_equal 'DEB HTTP://MY.SOURCES.LIST/DEBIAN MAIN CONTRIB NON-FREE', nfsroot_task.sources_list
    assert_equal 'PUBLIC_KEY', nfsroot_task.ssh_identity
    assert_equal 'SARGE', nfsroot_task.suite
  end


  # XXX installer_base -> nfsroot_base
  # XXX use sandbox.
  # XXX rename reXXX -> update_XXX
  def test_all_targets_should_be_defined
    Nfsroot.new.define_tasks

    Rake::Task.tasks.each do | each |
      puts each.name
    end

    assert_equal 8, Rake::Task.tasks.size

    assert Rake.application.lookup( '../.base/debian_etch.tgz' )
    assert Rake.application.lookup( './nfsroot' )
    assert Rake.application.lookup( 'installer:clobber_nfsroot_base' )
    assert Rake.application.lookup( 'installer:clobber_nfsroot' )
    assert Rake.application.lookup( 'installer:nfsroot_base' )
    assert Rake.application.lookup( 'installer:nfsroot' )
    assert Rake.application.lookup( 'installer:renfsroot_base' )
    assert Rake.application.lookup( 'installer:renfsroot' )
  end


  def test_nfsroot_task_execution___success___
    FileTest.expects( :exists? ).with do | value |
      value.kind_of?( String )
    end.at_least_once.returns( true )

    Popen3::Shell.expects( :logger= ).with( Lucie ).times( 1 )
    Popen3::Shell.expects( :open ).at_least_once.returns( 'DUMMY_RETURN_VALUE' )

    AptGet.expects( :apt ).at_least_once
    AptGet.expects( :check ).at_least_once
    AptGet.expects( :clean ).at_least_once
    AptGet.expects( :update ).at_least_once

    File.expects( :open ).at_least_once

    Nfsroot.configure do | task |
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.extra_packages = [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ]
      task.kernel_package = 'KERNEL.DEB'
      task.root_password = 'XXXXXXXX'
    end

    assert_nothing_raised do
      Rake::Task[ 'installer:nfsroot' ].execute
    end
  end


  def test_clobber_nfsroot_task_execution___success___
    File.expects( :exist? ).with( './nfsroot' ).times( 1 ).returns( true )

    Popen3::Shell.expects( :logger= ).with( Lucie ).times( 1 )
    Popen3::Shell.expects( :open ).at_least_once.returns( 'DUMMY_RETURN_VALUE' )

    Nfsroot.configure do | task |
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.extra_packages = [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ]
      task.kernel_package = 'KERNEL.DEB'
      task.root_password = 'XXXXXXXX'
    end

    Rake::Task[ 'installer:clobber_nfsroot' ].execute
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
