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
    installer_base_task = NfsrootBase.configure do | task |
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.include = [ 'INCLUDE' ]
    end

    assert_equal 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/', installer_base_task.mirror
    assert_equal 'DEBIAN', installer_base_task.distribution
    assert_equal 'SARGE', installer_base_task.suite
    assert_equal [ 'INCLUDE' ], installer_base_task.include
  end


  def test_all_targets_should_be_defined
    NfsrootBase.new.define_tasks

    assert_equal 4, Rake::Task.tasks.size

    assert Rake.application.lookup( File.expand_path( ENV[ 'RAILS_ROOT' ] + '/installers/.base/debian_etch.tgz' ) )
    assert Rake.application.lookup( 'installer:clobber_nfsroot_base' )
    assert Rake.application.lookup( 'installer:nfsroot_base' )
    assert Rake.application.lookup( 'installer:update_nfsroot_base' )
  end


  def test_installer_base_target_prerequisites_should_be_defined
    NfsrootBase.configure do | task |
      task.distribution = 'DEBIAN'
      task.suite = 'WOODY'
    end

    assert_equal [ File.expand_path( ENV[ 'RAILS_ROOT' ] + '/installers/.base/DEBIAN_WOODY.tgz' ) ], Rake::Task[ 'installer:nfsroot_base' ].prerequisites
  end


  def test_update_target_prerequisites_should_be_defined
    NfsrootBase.new.define_tasks

    assert_equal [ 'installer:clobber_nfsroot_base', 'installer:nfsroot_base' ], Rake::Task[ 'installer:update_nfsroot_base' ].prerequisites
  end


  def test_clobber_target_should___success___
    Popen3::Shell.expects( :open ).times( 1 ).returns( 'DUMMY_RETURN_VALUE' )

    NfsrootBase.new.define_tasks
    Rake::Task[ 'installer:clobber_nfsroot_base' ].execute
  end


  def test_tgz_target_should___success___
    Popen3::Shell.expects( :open ).at_least_once.returns( 'DUMMY_RETURN_VALUE' )
    Popen3::Debootstrap.expects( :new )
    AptGet.expects( :clean ).with( { :root => File.expand_path( ENV[ 'RAILS_ROOT' ] + '/installers/.base' ) } )

    NfsrootBase.configure do | task |
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
    end
    Rake::Task[ File.expand_path( ENV[ 'RAILS_ROOT' ] + '/installers/.base/DEBIAN_SARGE.tgz' ) ].execute
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
