#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname( __FILE__ ) + '/../test_helper'


class NfsrootBaseTest < Test::Unit::TestCase
  def teardown
    Rake::Task.clear
  end


  def test_accessor
    installer_base_task = NfsrootBase.new do | task |
      task.target_directory = '/TMP'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.include = [ 'INCLUDE' ]
    end

    assert_equal :nfsroot_base, installer_base_task.name
    assert_equal '/TMP', installer_base_task.target_directory
    assert_equal 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/', installer_base_task.mirror
    assert_equal 'DEBIAN', installer_base_task.distribution
    assert_equal 'SARGE', installer_base_task.suite
    assert_equal [ 'INCLUDE' ], installer_base_task.include
  end


  def test_all_targets_defined
    NfsrootBase.new do | task |
      task.target_directory = '/TMP'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
    end

    assert_kind_of Rake::Task, Rake::Task[ 'installer:nfsroot_base' ]
    assert_kind_of Rake::Task, Rake::Task[ 'installer:renfsroot_base' ]
    assert_kind_of Rake::Task, Rake::Task[ '/TMP/DEBIAN_SARGE.tgz' ]
  end


  def test_installer_base_target_prerequisites
    NfsrootBase.new do | task |
      task.target_directory = '/TMP/'
      task.distribution = 'DEBIAN'
      task.suite = 'WOODY'
    end
    assert_equal [ '/TMP/DEBIAN_WOODY.tgz' ], Rake::Task[ 'installer:nfsroot_base' ].prerequisites
  end


  def test_reinstaller_base_target_prerequisites
    NfsrootBase.new do | task |
      task.target_directory = '/TMP/'
      task.distribution = 'DEBIAN'
      task.suite = 'WOODY'
    end
    assert_equal [ "installer:clobber_nfsroot_base", "installer:nfsroot_base" ], Rake::Task[ 'installer:renfsroot_base' ].prerequisites
  end


  def test_clobber_target
    Popen3::Shell.expects( :open ).times( 1 ).returns( 'DUMMY_RETURN_VALUE' )

    NfsrootBase.new do | task |
      task.target_directory = '/TMP'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.include = [ 'INCLUDE' ]
    end

    Rake::Task[ 'installer:clobber_nfsroot_base' ].execute
  end


  def test_installer_base_target
    Popen3::Shell.expects( :open ).at_least_once.returns( 'DUMMY_RETURN_VALUE' )
    Popen3::Debootstrap.expects( :new )
    AptGet.expects( :clean ).with( { :root => '/TMP' } )

    NfsrootBase.new do | task |
      task.target_directory = '/TMP'
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.include = [ 'INCLUDE' ]
    end
    Rake::Task[ '/TMP/DEBIAN_SARGE.tgz' ].execute
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
