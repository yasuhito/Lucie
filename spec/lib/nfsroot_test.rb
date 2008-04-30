# [TODO] それぞれの describe... 内の before, after のリファクタリング


require File.dirname( __FILE__ ) + '/../spec_helper'


describe Nfsroot, 'when defining nfsroot rake tasks' do
  include FileSandbox


  before( :each ) do
    STDOUT.stubs :puts

    ENV[ 'INSTALLER_NAME' ] = 'INSTALLER_NAME'
    ENV[ 'BUILD_LABEL' ] = 'BUILD_LABEL'

    Rake::Task.clear
  end


  after( :each ) do
    ENV[ 'INSTALLER_NAME' ] = nil
    ENV[ 'BUILD_LABEL' ] = nil

    Rake::Task.clear
  end


  it 'should have accessors for nfsroot properties' do
    in_sandbox do | sandbox |
      # when
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

      # then
      nfsroot.target_directory.should == sandbox.root
      nfsroot.distribution.should == 'DEBIAN'
      nfsroot.arch.should == 'amd64'
      nfsroot.extra_packages.should == [ 'EXTRA_PACKAGE_1', 'EXTRA_PACKAGE_2' ]
      nfsroot.http_proxy.should == 'HTTP://PROXY/'
      nfsroot.kernel_package.should == 'KERNEL.DEB'
      nfsroot.mirror.should == 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      nfsroot.root_password.should == 'XXXXXXXX'
      nfsroot.sources_list.should == 'DEB HTTP://MY.SOURCES.LIST/DEBIAN MAIN CONTRIB NON-FREE'
      nfsroot.suite.should == 'SARGE'
    end
  end


  it 'should define all rake targets' do
    in_sandbox do | sandbox |
      # when
      Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end

      # then
      ## nfsroot_base tasks
      Rake.application.lookup( base_tgz_path ).should be_an_instance_of( Rake::FileTask )
      Rake.application.lookup( 'installer:clobber_nfsroot_base' ).should be_an_instance_of( Rake::Task )
      Rake.application.lookup( 'installer:nfsroot_base' ).should be_an_instance_of( Rake::Task )
      Rake.application.lookup( 'installer:rebuild_nfsroot_base' ).should be_an_instance_of( Rake::Task )

      ## nfsroot tasks
      Rake.application.lookup( sandbox.root ).should be_an_instance_of( Rake::FileCreationTask )
      Rake.application.lookup( 'installer:clobber_nfsroot' ).should be_an_instance_of( Rake::Task )
      Rake.application.lookup( 'installer:nfsroot' ).should be_an_instance_of( Rake::Task )
      Rake.application.lookup( 'installer:rebuild_nfsroot' ).should be_an_instance_of( Rake::Task )
    end
  end


  def base_tgz_path
    File.expand_path "#{ RAILS_ROOT }/installers/.base/debian_etch_i386.tgz"
  end
end


describe Nfsroot, 'when executing nfsroot rake tasks' do
  include FileSandbox


  before( :each ) do
    STDOUT.stubs :puts

    ENV[ 'INSTALLER_NAME' ] = 'INSTALLER_NAME'
    ENV[ 'BUILD_LABEL' ] = 'BUILD_LABEL'

    Rake::Task.clear
  end


  after( :each ) do
    ENV[ 'INSTALLER_NAME' ] = nil
    ENV[ 'BUILD_LABEL' ] = nil

    Rake::Task.clear
  end


  it 'should succeed to build nfsroot' do
    in_sandbox do | sandbox |
      # given
      nfsroot = Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end

      # stubs
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

      # when
      lambda do
        Rake::Task[ 'installer:nfsroot' ].execute( nil )
        # then
      end.should_not raise_error
    end
  end


  it 'should succeed to clobber nfsroot' do
    shell = Object.new

    in_sandbox do | sandbox |
      # given
      nfsroot = Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end

      # stubs
      Dir.stubs( :glob ).returns( [ 'DUMMY_RETURN_VALUE' ] )
      nfsroot.stubs( :sh_exec )
      shell.stubs( :on_stdout ).yields( 'DUMMY_LINE' )
      shell.stubs( :exec )
      Popen3::Shell.stubs( :open ).yields( shell )

      # when
      lambda do
        Rake::Task[ 'installer:clobber_nfsroot' ].execute( nil )
        # then
      end.should_not raise_error
    end
  end
end



describe Nfsroot, 'when executing sub nfsroot rake tasks' do
  include FileSandbox


  before( :each ) do
    STDOUT.stubs :puts

    ENV[ 'INSTALLER_NAME' ] = 'INSTALLER_NAME'
    ENV[ 'BUILD_LABEL' ] = 'BUILD_LABEL'

    Rake::Task.clear
  end


  after( :each ) do
    ENV[ 'INSTALLER_NAME' ] = nil
    ENV[ 'BUILD_LABEL' ] = nil

    Rake::Task.clear
  end


  it 'should hoaks packages' do
    nfsroot = Nfsroot.new
    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :get_kernel_version )

    file = Object.new
    file.stubs( :puts )
    File.stubs( :open ).yields( file )

    # when
    lambda do
      nfsroot.__send__ :hoaks_packages
      # then
    end.should_not raise_error
  end


  it 'should generate /etc/hosts' do
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

    # when
    lambda do
      nfsroot.__send__ :generate_etc_hosts
      # then
    end.should_not raise_error
  end


  it 'should umount_dirs' do
    nfsroot = Nfsroot.new
    nfsroot.stubs( :sh_exec )

    FileTest.stubs( :directory? ).returns( true )

    # when
    lambda do
      nfsroot.__send__ :umount_dirs
      # then
    end.should_not raise_error
  end


  it 'should add extra packages' do
    nfsroot = Nfsroot.new

    AptGet.stubs( :update )
    AptGet.stubs( :apt )
    AptGet.stubs( :clean )

    # when
    lambda do
      nfsroot.__send__ :add_packages_nfsroot
      # then
    end.should_not raise_error
  end


  it 'should get kernel version' do
    nfsroot = Nfsroot.new

    shell = Object.new
    shell.stubs( :on_stdout ).yields( ' Package: kernel-image-X.X.X' )
    shell.stubs( :exec )
    Popen3::Shell.stubs( :open ).yields( shell ).returns( 'DUMMY_VERSION' )

    # when
    lambda do
      nfsroot.__send__ :get_kernel_version
      # then
    end.should_not raise_error
  end


  it 'should install kernel' do
    nfsroot = Nfsroot.new

    Dir.stubs( :glob ).returns( [ 'BOOT-FILE' ] )
    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :get_kernel_version ).returns( 'X.X.X' )

    # when
    lambda do
      nfsroot.__send__ :install_kernel_nfsroot
      # then
    end.should_not raise_error
  end


  it 'should upgrade nfsroot' do
    nfsroot = Nfsroot.new

    AptGet.stubs( :update )
    AptGet.stubs( :check )
    AptGet.stubs( :apt )
    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :dpkg_divert )

    file = Object.new
    file.stubs( :puts )
    File.stubs( :open ).yields( file )

    # when
    lambda do
      nfsroot.__send__ :upgrade_nfsroot
      # then
    end.should_not raise_error
  end


  it 'should setup ssh' do
    nfsroot = Nfsroot.new

    ssh = Object.new
    ssh.stubs( :target_directory= )
    SSH.stubs( :setup ).yields( ssh )

    # when
    lambda do
      nfsroot.__send__ :setup_ssh
      # then
    end.should_not raise_error
  end


  it 'should setup dhcp' do
    nfsroot = Nfsroot.new

    nfsroot.stubs( :sh_exec )
    nfsroot.stubs( :get_kernel_version ).returns( 'X.X.X' )

    # when
    lambda do
      nfsroot.__send__ :setup_dhcp
      # then
    end.should_not raise_error
  end


  it 'should copy lucie files' do
    nfsroot = Nfsroot.new

    nfsroot.stubs( :sh_exec )

    # when
    lambda do
      nfsroot.__send__ :copy_lucie_files
      # then
    end.should_not raise_error
  end


  it 'should finalize nfsroot' do
    in_sandbox do | sandbox |
      nfsroot = Nfsroot.configure do | task |
        task.target_directory = sandbox.root
      end

      File.stubs( :open ).with( "#{ sandbox.root }/etc/gmond.conf", 'w' ).yields( StringIO.new )
      nfsroot.stubs( :sh_exec )
      FileTest.stubs( :directory? ).with( "#{ sandbox.root }/var/lib/discover" ).returns( false )
      FileTest.stubs( :directory? ).with( "#{ sandbox.root }/var/discover" ).returns( false )
      FileTest.stubs( :directory? ).with( "#{ sandbox.root }/var/yp" ).returns( true )

      # when
      lambda do
        nfsroot.__send__ :finish_nfsroot
        # then
      end.should_not raise_error
    end
  end


  it 'should check prerequisites' do
    FileTest.stubs( :exists? ).returns( true )

    # when
    lambda do
      Nfsroot.new.__send__ :check_prerequisites
      # then
    end.should_not raise_error
  end


  it 'should dpkg --divert' do
    nfsroot = Nfsroot.new

    nfsroot.stubs( :sh_exec )

    lambda do
      nfsroot.__send__ :dpkg_divert, [ 'DUMMY_FILE' ]
    end.should_not raise_error
  end
end


describe Nfsroot, 'when getting kernel version' do
  before( :each ) do
    STDOUT.stubs :puts

    ENV[ 'INSTALLER_NAME' ] = 'INSTALLER_NAME'
    ENV[ 'BUILD_LABEL' ] = 'BUILD_LABEL'

    Rake::Task.clear
  end


  after( :each ) do
    ENV[ 'INSTALLER_NAME' ] = nil
    ENV[ 'BUILD_LABEL' ] = nil

    Rake::Task.clear
  end


  it 'should fail if kernel_package option is not set' do
    nfsroot = Nfsroot.new

    nfsroot.stubs( :kernel_package ).returns( nil )

    lambda do
      nfsroot.__send__ :get_kernel_version
    end.should raise_error( RuntimeError, "Option ``kernel_package'' is not set." )
  end


  it 'should fail if dpkg command failed' do
    nfsroot = Nfsroot.new

    Popen3::Shell.stubs( :open ).returns( nil )

    lambda do
      nfsroot.__send__ :get_kernel_version
    end.should raise_error( RuntimeError, "Cannot determine kernel version." )
  end
end


describe Nfsroot, 'when instantiating without necessary environment variables' do
  before( :each ) do
    ENV[ 'INSTALLER_NAME' ] = nil
    ENV[ 'BUILD_LABEL' ] = nil
  end


  after( :each ) do
    ENV[ 'INSTALLER_NAME' ] = nil
    ENV[ 'BUILD_LABEL' ] = nil
  end


  it "should raise if ENV[ 'INSTALLER_NAME' ] is not set" do
    # when
    lambda do
      ENV[ 'BUILD_LABEL' ] = 'BUILD_LABEL'
      Nfsroot.new
      # then
    end.should raise_error( RuntimeError, "Environment variable 'INSTALLER_NAME' is not set.")
  end


  it "should raise if ENV[' BUILD_LABEL' ] is not set" do
    # when
    lambda do
      ENV[ 'INSTALLER_NAME' ] = 'INSTALLER_NAME'
      Nfsroot.new
      # then
    end.should raise_error( RuntimeError, "Environment variable 'BUILD_LABEL' is not set.")
  end
end


describe Nfsroot, 'when ON/OFF verbose option' do
  after( :each ) do
    ENV[ 'INSTALLER_NAME' ] = nil
    ENV[ 'BUILD_LABEL' ] = nil
  end


  it 'should succeed' do
    lambda do
      # when
      ENV[ 'INSTALLER_NAME' ] = 'INSTALLER_NAME'
      ENV[ 'BUILD_LABEL' ] = 'BUILD_LABEL'
      Nfsroot.new.verbose = true

      # then
    end.should_not raise_error
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
