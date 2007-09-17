require File.dirname( __FILE__ ) + '/../test_helper'
require 'lib/nfsroot'


class NfsrootTest < Test::Unit::TestCase
  include FileSandbox


  def teardown
    Rake::Task.clear
  end


  def test_accessor
    ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( '/RAILS_ROOT' )

    in_sandbox do | sandbox |
      nfsroot = Nfsroot.configure do | task |
        task.target_directory = sandbox.root
        task.distribution = 'DEBIAN'
        task.arch = 'amd64'
        task.extra_packages = [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ]
        task.http_proxy = 'HTTP://PROXY/'
        task.kernel_package = 'KERNEL.DEB'
        task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
        task.root_password = 'XXXXXXXX'
        task.sources_list = 'DEB HTTP://MY.SOURCES.LIST/DEBIAN MAIN CONTRIB NON-FREE'
        task.suite = 'SARGE'
      end

      assert_equal sandbox.root, nfsroot.target_directory
      assert_equal 'DEBIAN', nfsroot.distribution
      assert_equal 'amd64', nfsroot.arch
      assert_equal [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ], nfsroot.extra_packages
      assert_equal 'HTTP://PROXY/', nfsroot.http_proxy
      assert_equal 'KERNEL.DEB', nfsroot.kernel_package
      assert_equal 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/', nfsroot.mirror
      assert_equal 'XXXXXXXX', nfsroot.root_password
      assert_equal 'DEB HTTP://MY.SOURCES.LIST/DEBIAN MAIN CONTRIB NON-FREE', nfsroot.sources_list
      assert_equal 'SARGE', nfsroot.suite
    end
  end


  def test_all_targets_should_be_defined
    ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( '/RAILS_ROOT' )

    in_sandbox do | sandbox |
      nfsroot = Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end
      nfsroot.stubs( :rails_root ).returns( '/RAILS_ROOT' )

      assert Rake.application.lookup( ENV[ 'RAILS_ROOT' ] + '/installers/.base/debian_etch.tgz' )
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
    ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( '/RAILS_ROOT' )

    in_sandbox do | sandbox |
      nfsroot = Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end

      nfsroot.stubs( :sh_exec )
      nfsroot.stubs( :check_prerequisites )
      nfsroot.stubs( :hoaks_packages )
      nfsroot.stubs( :generate_etc_hosts )
      nfsroot.stubs( :upgrade_nfsroot )
      nfsroot.stubs( :add_packages_nfsroot )
      nfsroot.stubs( :copy_lucie_files )
      nfsroot.stubs( :copy_lucie_files )
      nfsroot.stubs( :finish_nfsroot )
      nfsroot.stubs( :install_kernel_nfsroot )
      nfsroot.stubs( :setup_ssh )
      nfsroot.stubs( :setup_dhcp )
      nfsroot.stubs( :umount_dirs )
      nfsroot.stubs( :rails_root ).returns( '/RAILS_ROOT' )

      assert_nothing_raised do
        Rake::Task[ 'installer:nfsroot' ].execute
      end
    end
  end


  def test_clobber_nfsroot_task_execution___success___
    ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( '/RAILS_ROOT' )

    in_sandbox do | sandbox |
      nfsroot = Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end

      Lucie::Log.stubs( :info )
      Dir.stubs( :glob ).returns( [ 'DUMMY_RETURN_VALUE' ] )
      nfsroot.stubs( :sh_exec )
      nfsroot.stubs( :rails_root ).returns( '/RAILS_ROOT' )
      shell = Object.new
      shell.stubs( :on_stdout ).yields( 'DUMMY_LINE' )
      shell.stubs( :exec )
      Popen3::Shell.stubs( :open ).yields( shell )

      Rake::Task[ 'installer:clobber_nfsroot' ].execute
    end
  end


  def test_kernel_package_file
    ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( '/RAILS_ROOT' )
    assert_equal '/RAILS_ROOT/kernels/linux-image-2.6.18-fai-kernels_1_i386.deb', Nfsroot.new.kernel_package_file
  end


  def test_hoaks_packages
    nfsroot = Nfsroot.new
    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :get_kernel_version )
    nfsroot.stubs( :rails_root ).returns( '/RAILS_ROOT' )

    file = Object.new
    file.stubs( :puts )
    File.stubs( :open ).yields( file )

    assert_nothing_raised do
      nfsroot.hoaks_packages
    end
  end


  def test_generate_etc_hosts
    nfsroot = Nfsroot.new

    hosts = Object.new
    hosts.stubs( :print )
    File.stubs( :open ).yields( hosts )
    shell = Object.new
    shell.stubs( :on_stdout ).yields( 'inet addr:??? ' )
    shell.stubs( :exec )
    Popen3::Shell.stubs( :open ).yields( shell )

    assert_nothing_raised do
      nfsroot.generate_etc_hosts
    end
  end


  def test_umount_dirs
    nfsroot = Nfsroot.new
    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :rails_root ).returns( '/RAILS_ROOT' )

    FileTest.stubs( :directory? ).returns( true )

    assert_nothing_raised do
      nfsroot.umount_dirs
    end
  end


  def test_add_packages_nfsroot
    nfsroot = Nfsroot.new

    Lucie::Log.stubs( :info )
    AptGet.stubs( :update )
    AptGet.stubs( :apt )
    AptGet.stubs( :clean )

    assert_nothing_raised do
      nfsroot.add_packages_nfsroot
    end
  end


  def test_kernel_version___fail___if_kernel_package_is_not_set
    nfsroot = Nfsroot.new

    nfsroot.stubs( :kernel_package ).returns( nil )
    assert_raises( "Option ``kernel_package'' is not set." ) do
      nfsroot.get_kernel_version
    end
  end


  def test_kernel_version___fail___if_dpkg_failed
    nfsroot = Nfsroot.new

    Popen3::Shell.stubs( :open ).returns( nil )

    assert_raises( "Cannot determine kernel version." ) do
      nfsroot.get_kernel_version
    end
  end


  def test_kernel_version___success___
    nfsroot = Nfsroot.new

    shell = Object.new
    shell.stubs( :on_stdout ).yields( ' Package: kernel-image-X.X.X' )
    shell.stubs( :exec )
    nfsroot.stubs( :rails_root ).returns( '/RAILS_ROOT' )
    Popen3::Shell.stubs( :open ).yields( shell ).returns( 'DUMMY_VERSION' )

    assert_nothing_raised do
      nfsroot.get_kernel_version
    end
  end


  def test_install_kernel_nfsroot
    nfsroot = Nfsroot.new

    Dir.stubs( :glob ).returns( [ 'BOOT-FILE' ] )
    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :get_kernel_version ).returns( 'X.X.X' )
    nfsroot.stubs( :rails_root ).returns( '/RAILS_ROOT' )

    assert_nothing_raised do
      nfsroot.install_kernel_nfsroot
    end
  end


  def test_upgrade_nfsroot
    nfsroot = Nfsroot.new

    Lucie::Log.stubs( :info )
    AptGet.stubs( :update )
    AptGet.stubs( :check )
    AptGet.stubs( :apt )
    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :dpkg_divert )
    nfsroot.stubs( :rails_root ).returns( '/RAILS_ROOT' )

    file = Object.new
    file.stubs( :puts )
    File.stubs( :open ).yields( file )

    assert_nothing_raised do
      nfsroot.upgrade_nfsroot
    end
  end


  def test_setup_ssh
    nfsroot = Nfsroot.new

    ssh = Object.new
    ssh.stubs( :target_directory= )
    SSH.stubs( :setup ).yields( ssh )

    assert_nothing_raised do
      nfsroot.setup_ssh
    end
  end


  def test_setup_dhcp
    nfsroot = Nfsroot.new

    Lucie::Log.stubs( :info )
    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :get_kernel_version ).returns( 'X.X.X' )
    nfsroot.stubs( :rails_root ).returns( '/RAILS_ROOT' )

    assert_nothing_raised do
      nfsroot.setup_dhcp
    end
  end


  def test_finish_nfsroot
    nfsroot = Nfsroot.new

    Lucie::Log.stubs( :info )
    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :rails_root ).returns( '/RAILS_ROOT' )
    FileTest.stubs( :directory? ).with( '../nfsroot/var/lib/discover' ).returns( false )
    FileTest.stubs( :directory? ).with( '../nfsroot/var/discover' ).returns( false )
    FileTest.stubs( :directory? ).with( '../nfsroot/var/yp' ).returns( true )

    assert_nothing_raised do
      nfsroot.finish_nfsroot
    end
  end


  def test_copy_lucie_files
    nfsroot = Nfsroot.new

    nfsroot.stubs( :sh_exec )

    assert_nothing_raised do
      nfsroot.copy_lucie_files
    end
  end


  def test_check_prerequisites___succcess___
    nfsroot = Nfsroot.new

    nfsroot.stubs( :rails_root ).returns( '/RAILS_ROOT' )
    FileTest.stubs( :exists? ).returns( true )

    assert_nothing_raised do
      nfsroot.check_prerequisites
    end
  end


  def test_check_prerequisites___fail___
    nfsroot = Nfsroot.new

    nfsroot.stubs( :rails_root ).returns( '/RAILS_ROOT' )

    assert_raises( RuntimeError ) do
      nfsroot.check_prerequisites
    end
  end


  def test_dpkg_divert
    nfsroot = Nfsroot.new

    nfsroot.stubs( :sh_exec )

    assert_nothing_raised do
      nfsroot.dpkg_divert [ 'DUMMY_FILE' ]
    end
  end


  def test_rails_root___success___
    ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( '/RAILS_ROOT' )

    assert_nothing_raised do
      Nfsroot.new.rails_root
    end
  end


  def test_rails_root___fail___
    ENV.stubs( :[] ).with( 'RAILS_ROOT' ).returns( nil )

    assert_raises( 'RAILS_ROOT is not set.' ) do
      Nfsroot.new.rails_root
    end
  end


  def test_verbose
    assert_nothing_raised do
      Nfsroot.new.verbose = true
    end
  end
end
