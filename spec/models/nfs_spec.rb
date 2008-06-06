#
# nfs_spec.rb - Rspec for Nfs model.
#


require File.dirname( __FILE__ ) + '/../spec_helper'


describe Nfs do
  before( :each ) do
    @nfs = Nfs.new
    Nfs.stubs( :new ).returns( @nfs )

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
  end


  describe 'when (re-)starting NFS daemon' do
    before( :each ) do
      @nfs.stubs( :generate_config_file )
    end


    it 'should raise an error if no NFS daemon installed' do
      File.stubs( :exists? ).with( '/etc/init.d/nfs-kernel-server' ).returns( false )

      lambda do
        Nfs.setup
      end.should raise_error( 'nfs-kernel-server package is not installed. Please install first.' )
    end


    describe 'with NFS daemon installed' do
      before( :each ) do
        File.stubs( :exists? ).with( '/etc/init.d/nfs-kernel-server' ).returns( 'INSTALLED' )
      end


      it 'should do nothing if there is no node' do
        Nodes.stubs( :load_all ).returns( [ ] )

        lambda do
          Nfs.setup
        end.should_not raise_error
      end


      describe 'and 2 nodes enabled' do
        before( :each ) do
          Nodes.stubs( :load_all ).returns( [ @node1, @node2 ] )
        end


        it 'should start NFS if nfsd is DOWN' do
          stub_nfsd_is_down

          @nfs.expects( :sh_exec ).with( '/etc/init.d/nfs-kernel-server start' ).returns( 'SUCCESS' )

          lambda do
            Nfs.setup
          end.should_not raise_error
        end


        it 'should reload NFS if nfsd is already UP' do
          stub_nfsd_is_up

          @nfs.expects( :sh_exec ).with( '/etc/init.d/nfs-kernel-server reload' ).returns( 'SUCCESS' )

          lambda do
            Nfs.setup
          end.should_not raise_error
        end


        def stub_nfsd_is_down
          @nfs.stubs( :system ).with( 'ps -U root -u root | grep nfsd' ).returns( false )
        end


        def stub_nfsd_is_up
          @nfs.stubs( :system ).with( 'ps -U root -u root | grep nfsd' ).returns( true )
        end
      end
    end
  end


  describe 'when generating /etc/exports' do
    before( :each ) do
      @nfs.stubs( :nfs_installed ).returns( 'INSTALLED' )
      @nfs.stubs( :nfsd_is_down )
      @nfs.stubs( :sh_exec )

      @config_file = Object.new
      File.stubs( :copy ).with( '/etc/exports', '/etc/exports.old' )
      File.stubs( :open ).with( '/etc/exports', 'w' ).yields( @config_file )
    end


    it 'should not export if no node enabled' do
      Nodes.stubs( :load_all ).returns( [ ] )

      @config_file.expects( :puts ).never

      Nfs.setup
    end


    it 'should export to 1 node if 1 node enabled' do
      Nodes.stubs( :load_all ).returns( [ @node1 ] )

      @config_file.expects( :puts ).with( "# NODE1" ).once
      @config_file.expects( :puts ).with( File.expand_path( "#{ RAILS_ROOT }/installers/TEST_INSTALLER NODE1_IP_ADDRESS(async,ro,no_root_squash,no_subtree_check)" ) ).once

      Nfs.setup
    end


    it 'should export to 1 node if 2 nodes enabled' do
      Nodes.stubs( :load_all ).returns( [ @node1, @node2 ] )

      @config_file.expects( :puts ).with( "# NODE1" ).once
      @config_file.expects( :puts ).with( File.expand_path( "#{ RAILS_ROOT }/installers/TEST_INSTALLER NODE1_IP_ADDRESS(async,ro,no_root_squash,no_subtree_check)" ) ).once
      @config_file.expects( :puts ).with( "# NODE2" ).once
      @config_file.expects( :puts ).with( File.expand_path( "#{ RAILS_ROOT }/installers/TEST_INSTALLER NODE2_IP_ADDRESS(async,ro,no_root_squash,no_subtree_check)" ) ).once

      Nfs.setup
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
