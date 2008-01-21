require File.dirname( __FILE__ ) + '/../test_helper'
require 'lib/nfsroot_base'


class NfsrootBaseTest < Test::Unit::TestCase
  def setup
    Rake::Task.clear
  end


  def teardown
    Rake::Task.clear
  end


  def test_accessor_methods
    installer_base_task = NfsrootBase.configure do | task |
      task.distribution = 'DEBIAN'
      task.http_proxy = 'HTTP://PROXY:3128'
      task.include = [ 'INCLUDE' ]
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.suite = 'SARGE'
      task.target_directory = '/TARGET_DIRECTORY'
    end

    assert_equal 'DEBIAN', installer_base_task.distribution
    assert_equal 'HTTP://PROXY:3128', installer_base_task.http_proxy
    assert_equal [ 'INCLUDE' ], installer_base_task.include
    assert_equal 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/', installer_base_task.mirror
    assert_equal 'SARGE', installer_base_task.suite
    assert_equal '/TARGET_DIRECTORY', installer_base_task.target_directory
  end


  def test_all_targets_defined
    NfsrootBase.new.define_tasks

    assert_equal 4, Rake::Task.tasks.size
    assert_kind_of Rake::FileTask, Rake.application.lookup( File.expand_path( "#{ RAILS_ROOT }/installers/.base/debian_etch.tgz" ) )
    assert_kind_of Rake::Task, Rake.application.lookup( 'installer:clobber_nfsroot_base' )
    assert_kind_of Rake::Task, Rake.application.lookup( 'installer:nfsroot_base' )
    assert_kind_of Rake::Task, Rake.application.lookup( 'installer:rebuild_nfsroot_base' )
  end


  def test_prerequisites_defined
    base_tgz_path = File.expand_path( "#{ RAILS_ROOT }/installers/.base/debian_etch.tgz" )

    NfsrootBase.new.define_tasks

    assert_equal [ base_tgz_path ], Rake::Task[ 'installer:nfsroot_base' ].prerequisites
    assert_equal [ 'installer:clobber_nfsroot_base', 'installer:nfsroot_base' ], Rake::Task[ 'installer:rebuild_nfsroot_base' ].prerequisites
    assert_equal [], Rake::Task[ base_tgz_path ].prerequisites
    assert_equal [], Rake::Task[ 'installer:clobber_nfsroot_base' ].prerequisites
  end


  def test_nfsroot_base_target_should___success___
    Lucie::Log.stubs( :info )

    nfsroot_base = NfsrootBase.configure do | task |
      task.target_directory = '/TMP'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.mirror = 'HTTP://MYHOST.COM/'
      task.http_proxy = 'http://PROXY/'
    end

    Debootstrap.expects( :start ).yields( debootstrap_option )
    nfsroot_base.expects( :sh_exec ).with( 'rm -f /TMP/etc/resolv.conf' )
    nfsroot_base.expects( :sh_exec ).with( 'mkdir /TMP' )
    nfsroot_base.expects( :sh_exec ).with( "tar --one-file-system --directory #{ RAILS_ROOT }/tmp/debootstrap --exclude DEBIAN_SARGE.tgz -czf /TMP/DEBIAN_SARGE.tgz ." )
    AptGet.expects( :clean ).with( :root => "#{ RAILS_ROOT }/tmp/debootstrap" )

    assert_nothing_raised do
      Rake::Task[ 'installer:nfsroot_base' ].invoke
    end
  end


  def test_clobber_target_should___success___
    nfsroot_base = NfsrootBase.configure do | task |
      task.target_directory = '/TMP'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
    end

    nfsroot_base.expects( :sh_exec ).with( "rm -rf #{ RAILS_ROOT }/tmp/debootstrap/*" ).times( 1 )

    Rake::Task[ 'installer:clobber_nfsroot_base' ].invoke
  end


  def test_rebuild___success___
    Lucie::Log.stubs( :info )

    nfsroot_base = NfsrootBase.configure do | task |
      task.target_directory = '/TMP'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.mirror = 'HTTP://MYHOST.COM/'
      task.http_proxy = 'http://PROXY/'
    end

    nfsroot_base.expects( :sh_exec ).with( "rm -rf #{ RAILS_ROOT }/tmp/debootstrap/*" )
    Debootstrap.expects( :start ).yields( debootstrap_option )
    nfsroot_base.expects( :sh_exec ).with( 'rm -f /TMP/etc/resolv.conf' )
    nfsroot_base.expects( :sh_exec ).with( 'mkdir /TMP' )
    nfsroot_base.expects( :sh_exec ).with( "tar --one-file-system --directory #{ RAILS_ROOT }/tmp/debootstrap --exclude DEBIAN_SARGE.tgz -czf /TMP/DEBIAN_SARGE.tgz ." )
    AptGet.expects( :clean ).with( :root => "#{ RAILS_ROOT }/tmp/debootstrap" )

    assert_nothing_raised do
      Rake::Task[ 'installer:rebuild_nfsroot_base' ].invoke
    end
  end


  private


  def debootstrap_option
    option = Object.new
    option.expects( :env= ).with( { 'LC_ALL' => 'C', 'http_proxy' => 'http://PROXY/' } )
    option.expects( :exclude= )
    option.expects( :suite= )
    option.expects( :target= )
    option.expects( :mirror= )
    option.expects( :include= )

    return option
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
