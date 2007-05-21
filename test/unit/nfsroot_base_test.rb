#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname( __FILE__ ) + '/../test_helper'


class NfsrootBaseTest < Test::Unit::TestCase
  include FileSandbox


  def teardown
    Rake::Task.clear
  end


  def test_accessor_methods
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

    base_tgz_path = File.expand_path( ENV[ 'RAILS_ROOT' ] + '/installers/.base/debian_etch.tgz' )
    assert Rake.application.lookup( base_tgz_path )
    assert Rake.application.lookup( 'installer:clobber_nfsroot_base' )
    assert Rake.application.lookup( 'installer:nfsroot_base' )
    assert Rake.application.lookup( 'installer:rebuild_nfsroot_base' )
  end


  def test_nfsroot_base_target_prerequisites_should_be_defined
    NfsrootBase.new.define_tasks

    base_tgz_path = File.expand_path( ENV[ 'RAILS_ROOT' ] + '/installers/.base/debian_etch.tgz' )
    assert_equal [ base_tgz_path ], Rake::Task[ 'installer:nfsroot_base' ].prerequisites
  end


  def test_rebuild_target_prerequisites_should_be_defined
    NfsrootBase.new.define_tasks

    assert_equal [ 'installer:clobber_nfsroot_base', 'installer:nfsroot_base' ], Rake::Task[ 'installer:rebuild_nfsroot_base' ].prerequisites
  end


  def test_tgz_target_prerequisites_should_be_empty
    NfsrootBase.new.define_tasks

    base_tgz_path = File.expand_path( ENV[ 'RAILS_ROOT' ] + '/installers/.base/debian_etch.tgz' )
    assert_equal [], Rake::Task[ base_tgz_path ].prerequisites
  end


  def test_clobber_target_prerequisites_should_be_empty
    NfsrootBase.new.define_tasks

    assert_equal [], Rake::Task[ 'installer:clobber_nfsroot_base' ].prerequisites
  end


  def test_clobber_target_should___success___
    in_sandbox do | sandbox |
      Popen3::Shell.expects( :open ).times( 1 ).returns( 'DUMMY_RETURN_VALUE' )
      
      NfsrootBase.configure do | task |
        task.target_directory = sandbox.root
        task.distribution = 'DEBIAN'
        task.suite = 'SARGE'
      end

      Rake::Task[ 'installer:clobber_nfsroot_base' ].invoke
    end
  end


  def test_rebuild_target_should___success___
    in_sandbox do | sandbox |
      Popen3::Shell.expects( :open ).at_least_once.returns( 'DUMMY_RETURN_VALUE' )
      Popen3::Debootstrap.expects( :new )
      Lucie::Log.expects( :info ).at_least_once
      AptGet.expects( :clean ).with( { :root => sandbox.root } )
      
      NfsrootBase.configure do | task |
        task.target_directory = sandbox.root
        task.distribution = 'DEBIAN'
        task.suite = 'SARGE'
      end

      Rake::Task[ 'installer:rebuild_nfsroot_base' ].invoke
    end
  end


  def test_nfsroot_base_target_should___success___
    in_sandbox do | sandbox |
      Lucie::Log.expects( :info ).at_least_once
      Popen3::Debootstrap.expects( :new )
      AptGet.expects( :clean ).with( { :root => sandbox.root } )
      Popen3::Shell.expects( :open ).at_least_once.returns( 'DUMMY_RETURN_VALUE' )

      NfsrootBase.configure do | task |
        task.target_directory = sandbox.root
        task.distribution = 'DEBIAN'
        task.suite = 'SARGE'
      end

      Rake::Task[ 'installer:nfsroot_base' ].invoke
    end
  end


  def test_tgz_target_should___success___
    in_sandbox do | sandbox |
      Lucie::Log.expects( :info ).at_least_once
      Popen3::Debootstrap.expects( :new )
      AptGet.expects( :clean ).with( { :root => sandbox.root } )
      Popen3::Shell.expects( :open ).at_least_once.returns( 'DUMMY_RETURN_VALUE' )
      
      NfsrootBase.configure do | task |
        task.target_directory = sandbox.root
        task.distribution = 'DEBIAN'
        task.suite = 'SARGE'
      end
      
      Rake::Task[ File.expand_path( sandbox.root + '/DEBIAN_SARGE.tgz' ) ].invoke
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
