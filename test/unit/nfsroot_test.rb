require File.dirname( __FILE__ ) + '/../test_helper'
require 'lib/nfsroot'


class NfsrootTest < Test::Unit::TestCase
  include FileSandbox


  def setup
    ENV[ 'INSTALLER_NAME' ] = 'INSTALLER_NAME'
    Lucie::Log.stubs( :info )
    Rake::Task.clear
  end


  def teardown
    ENV[ 'INSTALLER_NAME' ] = nil
    Rake::Task.clear
  end


  def test_accessor
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
    in_sandbox do | sandbox |
      nfsroot = Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end

      # nfsroot_base tasks
      assert_kind_of Rake::FileTask, Rake.application.lookup( File.expand_path( "#{ RAILS_ROOT }/installers/.base/debian_etch_i386.tgz" ) )
      assert_kind_of Rake::Task, Rake.application.lookup( 'installer:clobber_nfsroot_base' )
      assert_kind_of Rake::Task, Rake.application.lookup( 'installer:nfsroot_base' )
      assert_kind_of Rake::Task, Rake.application.lookup( 'installer:rebuild_nfsroot_base' )

      # nfsroot tasks
      assert_kind_of Rake::Task, Rake.application.lookup( sandbox.root )
      assert_kind_of Rake::Task, Rake.application.lookup( 'installer:clobber_nfsroot' )
      assert_kind_of Rake::Task, Rake.application.lookup( 'installer:nfsroot' )
      assert_kind_of Rake::Task, Rake.application.lookup( 'installer:rebuild_nfsroot' )
    end
  end


  def test_nfsroot_task_execution___success___
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
      nfsroot.stubs( :finish_nfsroot )
      nfsroot.stubs( :install_kernel_nfsroot )
      nfsroot.stubs( :setup_ssh )
      nfsroot.stubs( :setup_dhcp )
      nfsroot.stubs( :umount_dirs )

      assert_nothing_raised do
        Rake::Task[ 'installer:nfsroot' ].execute
      end
    end
  end


  def test_clobber_nfsroot_task_execution___success___
    shell = Object.new

    in_sandbox do | sandbox |
      nfsroot = Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end

      Dir.stubs( :glob ).returns( [ 'DUMMY_RETURN_VALUE' ] )
      nfsroot.stubs( :sh_exec )
      shell.stubs( :on_stdout ).yields( 'DUMMY_LINE' )
      shell.stubs( :exec )
      Popen3::Shell.stubs( :open ).yields( shell )

      Rake::Task[ 'installer:clobber_nfsroot' ].execute
    end
  end


  def test_kernel_package_file
    assert_equal "#{ RAILS_ROOT }/kernels/linux-image-2.6.18-fai-kernels_1_i386.deb", Nfsroot.new.kernel_package_file
  end


  def test_hoaks_packages
    nfsroot = Nfsroot.new
    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :get_kernel_version )

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

    node_list = Object.new
    node_list.stubs( :each )
    Nodes.stubs( :load_all ).returns( node_list )

    assert_nothing_raised do
      nfsroot.generate_etc_hosts
    end
  end


  def test_umount_dirs
    nfsroot = Nfsroot.new
    nfsroot.stubs( :sh_exec )

    FileTest.stubs( :directory? ).returns( true )

    assert_nothing_raised do
      nfsroot.umount_dirs
    end
  end


  def test_add_packages_nfsroot
    nfsroot = Nfsroot.new

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

    assert_nothing_raised do
      nfsroot.install_kernel_nfsroot
    end
  end


  def test_upgrade_nfsroot
    nfsroot = Nfsroot.new

    AptGet.stubs( :update )
    AptGet.stubs( :check )
    AptGet.stubs( :apt )
    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :dpkg_divert )

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

    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :get_kernel_version ).returns( 'X.X.X' )

    assert_nothing_raised do
      nfsroot.setup_dhcp
    end
  end


  def test_finish_nfsroot
    in_sandbox do | sandbox |
      nfsroot = Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end

      File.stubs( :open ).with( "#{ sandbox.root }/etc/gmond.conf", 'w' ).yields( StringIO.new )
      nfsroot.stubs( :sh_exec )
      FileTest.stubs( :directory? ).with( "#{ sandbox.root }/var/lib/discover" ).returns( false )
      FileTest.stubs( :directory? ).with( "#{ sandbox.root }/var/discover" ).returns( false )
      FileTest.stubs( :directory? ).with( "#{ sandbox.root }/var/yp" ).returns( true )

      assert_nothing_raised do
        nfsroot.finish_nfsroot
      end
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
    FileTest.stubs( :exists? ).returns( true )

    assert_nothing_raised do
      Nfsroot.new.check_prerequisites
    end
  end


  def test_dpkg_divert
    nfsroot = Nfsroot.new

    nfsroot.stubs( :sh_exec )

    assert_nothing_raised do
      nfsroot.dpkg_divert [ 'DUMMY_FILE' ]
    end
  end


  def test_verbose
    assert_nothing_raised do
      Nfsroot.new.verbose = true
    end
  end
end
