require File.dirname( __FILE__ ) + '/../spec_helper'


describe NfsrootBase, 'when defining nfsroot base rake tasks' do
  before( :each ) do
    Rake::Task.clear
  end


  after( :each ) do
    Rake::Task.clear
  end


  it 'should have accessors for nfsroot base properties' do
    # when
    installer_base_task = NfsrootBase.configure do | task |
      task.arch = 'AMD64'
      task.distribution = 'DEBIAN'
      task.http_proxy = 'HTTP://PROXY:3128'
      task.include = [ 'PACKAGES', 'TO', 'BE', 'INCLUDED' ]
      task.mirror = 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
      task.suite = 'SARGE'
      task.target_directory = '/TARGET_DIRECTORY'
    end

    # then
    installer_base_task.arch.should == 'AMD64'
    installer_base_task.distribution.should == 'DEBIAN'
    installer_base_task.http_proxy.should == 'HTTP://PROXY:3128'
    installer_base_task.include.should == [ 'PACKAGES', 'TO', 'BE', 'INCLUDED' ]
    installer_base_task.mirror.should == 'HTTP://WWW.DEBIAN.OR.JP/DEBIAN/'
    installer_base_task.suite.should == 'SARGE'
    installer_base_task.target_directory.should == '/TARGET_DIRECTORY'
  end


  it 'should define all rake targets' do
    # when
    NfsrootBase.new.define_tasks

    # then
    Rake::Task.tasks.size.should == 4
    Rake.application.lookup( base_tgz_path ).should be_an_instance_of( Rake::FileTask )
    Rake.application.lookup( 'installer:clobber_nfsroot_base' ).should be_an_instance_of( Rake::Task )
    Rake.application.lookup( 'installer:nfsroot_base' ).should be_an_instance_of( Rake::Task )
    Rake.application.lookup( 'installer:rebuild_nfsroot_base' ).should be_an_instance_of( Rake::Task )
  end


  it 'should define all prerequisites' do
    # when
    NfsrootBase.new.define_tasks

    # then
    Rake::Task[ 'installer:nfsroot_base' ].prerequisites.should == [ base_tgz_path ]
    Rake::Task[ 'installer:rebuild_nfsroot_base' ].prerequisites.should == [ 'installer:clobber_nfsroot_base', 'installer:nfsroot_base' ]
    Rake::Task[ base_tgz_path ].prerequisites.should == []
    Rake::Task[ 'installer:clobber_nfsroot_base' ].prerequisites.should == []
  end


  def base_tgz_path
    File.expand_path "#{ RAILS_ROOT }/installers/.base/debian_etch_i386.tgz"
  end
end


describe NfsrootBase, 'when executing nfsroot base rake tasks' do
  before( :each ) do
    STDOUT.stubs( :puts )
    Lucie::Log.stubs( :info )
    Rake::Task.clear
  end


  after( :each ) do
    Rake::Task.clear
  end


  it 'should succcess to build nfsroot base' do
    # given
    nfsroot_base = NfsrootBase.configure do | task |
      task.arch = 'i386'
      task.target_directory = '/TMP'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.mirror = 'HTTP://MYHOST.COM/'
      task.http_proxy = 'http://PROXY/'
    end

    # expects
    Debootstrap.expects( :start ).yields( debootstrap_option )
    nfsroot_base.expects( :sh_exec ).with( 'rm -f /TMP/etc/resolv.conf' )
    nfsroot_base.expects( :sh_exec ).with( 'mkdir /TMP' )
    nfsroot_base.expects( :sh_exec ).with( "tar --one-file-system --directory #{ RAILS_ROOT }/tmp/debootstrap.i386 --exclude DEBIAN_SARGE_i386.tgz -czf /TMP/DEBIAN_SARGE_i386.tgz ." )
    AptGet.expects( :clean ).with( :root => "#{ RAILS_ROOT }/tmp/debootstrap.i386" )

    # when
    lambda do
      Rake::Task[ 'installer:nfsroot_base' ].invoke
      # then
    end.should_not raise_error
  end


  it 'should success to clobber nfsroot base' do
    # given
    nfsroot_base = NfsrootBase.configure do | task |
      task.arch = 'i386'
      task.target_directory = '/TMP'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
    end

    # expects
    nfsroot_base.expects( :sh_exec ).with( "rm -rf #{ RAILS_ROOT }/tmp/debootstrap.i386/*" ).times( 1 )

    # when
    lambda do
      Rake::Task[ 'installer:clobber_nfsroot_base' ].invoke
      # then
    end.should_not raise_error
  end


  it 'should success to rebuild' do
    # given
    nfsroot_base = NfsrootBase.configure do | task |
      task.arch = 'i386'
      task.target_directory = '/TMP'
      task.distribution = 'DEBIAN'
      task.suite = 'SARGE'
      task.mirror = 'HTTP://MYHOST.COM/'
      task.http_proxy = 'http://PROXY/'
    end

    # expects
    nfsroot_base.expects( :sh_exec ).with( "rm -rf #{ RAILS_ROOT }/tmp/debootstrap.i386/*" )
    Debootstrap.expects( :start ).yields( debootstrap_option )
    nfsroot_base.expects( :sh_exec ).with( 'rm -f /TMP/etc/resolv.conf' )
    nfsroot_base.expects( :sh_exec ).with( 'mkdir /TMP' )
    nfsroot_base.expects( :sh_exec ).with( "tar --one-file-system --directory #{ RAILS_ROOT }/tmp/debootstrap.i386 --exclude DEBIAN_SARGE_i386.tgz -czf /TMP/DEBIAN_SARGE_i386.tgz ." )
    AptGet.expects( :clean ).with( :root => "#{ RAILS_ROOT }/tmp/debootstrap.i386" )

    # when
    lambda do
      Rake::Task[ 'installer:rebuild_nfsroot_base' ].invoke
      # then
    end.should_not raise_error
  end


  def debootstrap_option
    option = Object.new
    option.expects( :arch= ).with( 'i386' )
    option.expects( :env= ).with( { 'LC_ALL' => 'C', 'http_proxy' => 'http://PROXY/' } )
    option.expects( :exclude= )
    option.expects( :suite= )
    option.expects( :target= )
    option.expects( :mirror= )
    option.expects( :include= )

    option
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
