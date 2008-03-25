require File.dirname( __FILE__ ) + '/../spec_helper'


describe 'Common NFS', :shared => true do
  before( :each ) do
    @nfs = Nfs.new
    @exports = Object.new

    @node1 = Object.new
    @node1.stubs( :name ).returns( 'NODE1' )
    @node1.stubs( :ip_address ).returns( 'NODE1_IP_ADDRESS' )
    @node1.stubs( :enable? ).returns( true )
    @node1.stubs( :installer_name ).returns( 'TEST_INSTALLER' )

    @node2 = Object.new
    @node2.stubs( :name ).returns( 'NODE2' )
    @node2.stubs( :ip_address ).returns( 'NODE2_IP_ADDRESS' )
    @node2.stubs( :enable? ).returns( true )
    @node2.stubs( :installer_name ).returns( 'TEST_INSTALLER' )

    Nfs.stubs( :new ).returns( @nfs )
  end
end


describe Nfs, 'when generating /etc/exports' do
  it_should_behave_like 'Common NFS'


  before( :each ) do
    File.stubs( :copy ).with( '/etc/exports', '/etc/exports.old' )
    File.stubs( :open ).with( '/etc/exports', 'w' ).yields( @exports )
    @nfs.stubs( :nfsd_is_down ).returns( false )
    @nfs.stubs( :sh_exec )
    Installer.stubs( :path ).returns( File.expand_path( "#{ RAILS_ROOT }/installers/TEST_INSTALLER" ) ).times( 2 )
  end


  it 'should do nothing if there is no node' do
    # given
    Nodes.stubs( :load_all ).returns( [ ] )

    # when
    Nfs.setup
  end


  it 'should export to 1 node' do
    # given
    Nodes.stubs( :load_all ).returns( [ @node1 ] )

    # then
    @exports.expects( :puts ).with( "# NODE1")
    @exports.expects( :puts ).with( File.expand_path( "#{ RAILS_ROOT }/installers/TEST_INSTALLER NODE1_IP_ADDRESS(async,ro,no_root_squash,no_subtree_check)" ) )

    # when
    Nfs.setup
  end


  it 'should export to 2 nodes' do
    # given
    Nodes.stubs( :load_all ).returns( [ @node1, @node2 ] )

    # then
    @exports.expects( :puts ).with( "# NODE1" )
    @exports.expects( :puts ).with( File.expand_path( "#{ RAILS_ROOT }/installers/TEST_INSTALLER NODE1_IP_ADDRESS(async,ro,no_root_squash,no_subtree_check)" ) )
    @exports.expects( :puts ).with( "# NODE2" )
    @exports.expects( :puts ).with( File.expand_path( "#{ RAILS_ROOT }/installers/TEST_INSTALLER NODE2_IP_ADDRESS(async,ro,no_root_squash,no_subtree_check)" ) )

    # when
    Nfs.setup
  end
end


describe Nfs, 'when controlling nfsd' do
  it_should_behave_like 'Common NFS'


  before( :each ) do
    @exports.stubs( :puts )
    File.stubs( :copy )
    File.stubs( :open ).yields( @exports )
    Installer.stubs( :path )
    Nodes.stubs( :load_all ).returns( [ @node1, @node2 ] )
  end


  it 'should start the nfs daemon if nfsd is down' do
    # given, then
    @nfs.expects( :nfsd_is_down ).returns( true )
    @nfs.expects( :sh_exec ).with( '/etc/init.d/nfs-kernel-server start' )

    # when
    Nfs.setup
  end


  it 'should reload the nfs daemon if nfsd is up' do
    # given, then
    @nfs.expects( :nfsd_is_down ).returns( false )
    @nfs.expects( :sh_exec ).with( '/etc/init.d/nfs-kernel-server reload' )

    # when
    Nfs.setup
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
