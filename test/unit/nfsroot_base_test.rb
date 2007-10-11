require File.dirname( __FILE__ ) + '/../test_helper'
require 'lib/nfsroot_base'


class NfsrootBaseTest < Test::Unit::TestCase
  include FileSandbox


  def teardown
    Rake::Task.clear
  end


  def test_accessor_methods
    ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( '/RAILS_ROOT' )

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
    ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( '/RAILS_ROOT' )

    NfsrootBase.new.define_tasks
    base_tgz_path = File.expand_path( ENV[ 'RAILS_ROOT' ] + '/installers/.base/debian_etch.tgz' )

    assert_equal 4, Rake::Task.tasks.size
    assert Rake.application.lookup( base_tgz_path )
    assert Rake.application.lookup( 'installer:clobber_nfsroot_base' )
    assert Rake.application.lookup( 'installer:nfsroot_base' )
    assert Rake.application.lookup( 'installer:rebuild_nfsroot_base' )
  end


  def test_prerequisites
    ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( '/RAILS_ROOT' )

    NfsrootBase.new.define_tasks

    base_tgz_path = File.expand_path( ENV[ 'RAILS_ROOT' ] + '/installers/.base/debian_etch.tgz' )
    assert_equal [ base_tgz_path ], Rake::Task[ 'installer:nfsroot_base' ].prerequisites
    assert_equal [ 'installer:clobber_nfsroot_base', 'installer:nfsroot_base' ], Rake::Task[ 'installer:rebuild_nfsroot_base' ].prerequisites
    assert_equal [], Rake::Task[ base_tgz_path ].prerequisites
    assert_equal [], Rake::Task[ 'installer:clobber_nfsroot_base' ].prerequisites
  end


  def test_clobber_target_should___success___
    ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( '/RAILS_ROOT' )

    nfsroot_base = NfsrootBase.configure do | task |
      task.target_directory = '/TMP'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
    end

    nfsroot_base.expects( :sh_exec ).with( 'rm', '-rf', '/RAILS_ROOT/tmp/debootstrap/*' ).times( 1 )

    Rake::Task[ 'installer:clobber_nfsroot_base' ].invoke
  end


#   def test_rebuild___success___
#     ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( '/RAILS_ROOT' )

#     nfsroot_base = NfsrootBase.configure do | task |
#       task.target_directory = '/TMP'
#       task.distribution = 'DEBIAN'
#       task.suite = 'SARGE'
#       task.mirror = 'HTTP://MYHOST.COM/'
#     end

#     Popen3::Debootstrap.stubs( :VERSION )
#     Lucie::Log.stubs( :info )
#     option = Object.new
#     option.stubs( :env= )
#     option.stubs( :exclude= )
#     option.stubs( :suite= )
#     option.stubs( :target= )
#     option.stubs( :mirror= )
#     option.stubs( :include= )
#     nfsroot_base.stubs( :debootstrap ).yields( option )
#     AptGet.expects( :clean ).with( { :root => ENV[ 'RAILS_ROOT' ] + '/tmp/debootstrap' } )      
#     nfsroot_base.stubs( :sh_exec )

#     assert_nothing_raised do
#       Rake::Task[ 'installer:rebuild_nfsroot_base' ].invoke
#     end
#   end


  def test_rails_root
    ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( nil )

    assert_raises( 'RAILS_ROOT is not set.' ) do
      NfsrootBase.new.rails_root
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
