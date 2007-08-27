require File.dirname( __FILE__ ) + '/../test_helper'


require 'rake'


class NfsrootTest < Test::Unit::TestCase
  include FileSandbox


  def teardown
    Rake::Task.clear
  end


  def test_accessor
    in_sandbox do | sandbox |
      nfsroot_task = Nfsroot.configure do | task |
        task.target_directory = sandbox.root
        task.distribution = 'DEBIAN'
        task.extra_packages = [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ]
        task.http_proxy = 'HTTP://PROXY/'
        task.kernel_package = 'KERNEL.DEB'
        task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
        task.root_password = 'XXXXXXXX'
        task.sources_list = 'DEB HTTP://MY.SOURCES.LIST/DEBIAN MAIN CONTRIB NON-FREE'
        task.suite = 'SARGE'
      end

      assert_equal sandbox.root, nfsroot_task.target_directory
      assert_equal 'DEBIAN', nfsroot_task.distribution
      assert_equal [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ], nfsroot_task.extra_packages
      assert_equal 'HTTP://PROXY/', nfsroot_task.http_proxy
      assert_equal 'KERNEL.DEB', nfsroot_task.kernel_package
      assert_equal 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/', nfsroot_task.mirror
      assert_equal 'XXXXXXXX', nfsroot_task.root_password
      assert_equal 'DEB HTTP://MY.SOURCES.LIST/DEBIAN MAIN CONTRIB NON-FREE', nfsroot_task.sources_list
      assert_equal 'SARGE', nfsroot_task.suite
    end
  end


  def test_all_targets_should_be_defined
    in_sandbox do | sandbox |
      nfsroot_task = Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end

      assert Rake.application.lookup( File.expand_path( '../installers/.base/debian_etch.tgz' ) )
      assert Rake.application.lookup( sandbox.root )
      assert Rake.application.lookup( 'installer:clobber_nfsroot' )
      assert Rake.application.lookup( 'installer:clobber_nfsroot_base' )
      assert Rake.application.lookup( 'installer:nfsroot' )
      assert Rake.application.lookup( 'installer:nfsroot_base' )
      assert Rake.application.lookup( 'installer:rebuild_nfsroot' )
      assert Rake.application.lookup( 'installer:rebuild_nfsroot_base' )
    end
  end


  def test_nfsroot_task_execution___success___
    in_sandbox do | sandbox |
      Lucie::Log.expects( :info ).at_least_once

      FileTest.expects( :exists? ).with do | value |
        value.kind_of?( String )
      end.at_least_once.returns( true )

      Popen3::Shell.expects( :open ).at_least_once.returns( 'DUMMY_RETURN_VALUE' )

      AptGet.expects( :apt ).at_least_once
      AptGet.expects( :check ).at_least_once
      AptGet.expects( :clean ).at_least_once
      AptGet.expects( :update ).at_least_once

      File.expects( :open ).at_least_once

      SSH.expects( :setup ).times( 1 )

      Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end

      assert_nothing_raised do
        Rake::Task[ 'installer:nfsroot' ].execute
      end
    end
  end


  def test_clobber_nfsroot_task_execution___success___
    in_sandbox do | sandbox |
      File.expects( :exist? ).with( sandbox.root ).times( 1 ).returns( true )

      Lucie::Log.expects( :info ).at_least_once

      Popen3::Shell.expects( :open ).at_least_once.returns( 'DUMMY_RETURN_VALUE' )

      Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end

      Rake::Task[ 'installer:clobber_nfsroot' ].execute
    end
  end
end
