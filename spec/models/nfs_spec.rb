require File.dirname( __FILE__ ) + '/../spec_helper'


describe Nfs do
  before( :each ) do
    @nfs = Nfs.new
    @file = Object.new

    @node1 = Object.new
    @node1.stubs( :name ).returns( 'NODE1' )
    @node1.stubs( :enable? ).returns( true )
    @node1.stubs( :installer_name ).returns( 'TEST_INSTALLER' )

    @node2 = Object.new
    @node2.stubs( :name ).returns( 'NODE2' )
    @node2.stubs( :enable? ).returns( true )
    @node2.stubs( :installer_name ).returns( 'TEST_INSTALLER' )

    Nfs.stubs( :new ).returns( @nfs )
  end


  it 'should do nothing if there is no node' do
    # given
    Nodes.stubs( :load_all ).returns( [ ] )

    # expects
    File.expects( :copy ).with( '/etc/exports', '/etc/exports.old' )
    File.expects( :open ).with( '/etc/exports', 'w' ).yields( @file )
    @nfs.expects( :sh_exec ).with( '/etc/init.d/nfs-kernel-server restart' )

    # when
    lambda do
      Nfs.setup

      # then
    end.should_not raise_error
  end


  it 'should setup nfs daemon if there is 1 node' do
    # given
    Nodes.stubs( :load_all ).returns( [ @node1 ] )

    # expects
    File.expects( :copy ).with( '/etc/exports', '/etc/exports.old' )
    File.expects( :open ).with( '/etc/exports', 'w' ).yields( @file )
    @file.expects( :puts ).with( File.expand_path( "#{ RAILS_ROOT }/installers/TEST_INSTALLER/nfsroot NODE1(async,ro,no_root_squash,no_subtree_check)" ) )
    @nfs.expects( :sh_exec ).with( '/etc/init.d/nfs-kernel-server restart' )

    # when
    lambda do
      Nfs.setup

      # then
    end.should_not raise_error
  end


  it 'should setup nfs daemon if there are 2 nodes' do
    # given
    Nodes.stubs( :load_all ).returns( [ @node1, @node2 ] )

    # expects
    File.expects( :copy ).with( '/etc/exports', '/etc/exports.old' )
    File.expects( :open ).with( '/etc/exports', 'w' ).yields( @file )
    @file.expects( :puts ).with( File.expand_path( "#{ RAILS_ROOT }/installers/TEST_INSTALLER/nfsroot NODE1(async,ro,no_root_squash,no_subtree_check)" ) )
    @file.expects( :puts ).with( File.expand_path( "#{ RAILS_ROOT }/installers/TEST_INSTALLER/nfsroot NODE2(async,ro,no_root_squash,no_subtree_check)" ) )
    @nfs.expects( :sh_exec ).with( '/etc/init.d/nfs-kernel-server restart' )

    # when
    lambda do
      Nfs.setup

      # then
    end.should_not raise_error
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
