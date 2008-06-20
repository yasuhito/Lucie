#
# tftp_spec.rb - Rspec for Tftp model.
#


require File.dirname( __FILE__ ) + '/../spec_helper'


describe Tftp do
  include FileSandbox


  before( :each ) do
    @tftp = Tftp.new
    Tftp.stubs( :new ).returns( @tftp )

    @node = Object.new
    @node.stubs( :name ).returns( 'NODE_NAME' )
    @node.stubs( :mac_address ).returns( 'AA:BB:CC:DD:EE:FF' )
  end


  ################################################################################
  # Tftp.setup
  ################################################################################


  describe 'when setting up TFTPD' do
    before( :each ) do
      @net_tftp = Object.new
      Net::TFTP.stubs( :open ).returns( @net_tftp )
    end


    it 'should succeed to generate PXE config file' do
      @tftp.stubs( :setup_tftpd )

      in_sandbox do | sandbox |
        build_statuses = Object.new
        build_statuses.stubs( :last_complete_build_status ).returns( 'OK' )
        Installer.stubs( :new ).returns( build_statuses )

        Configuration.stubs( :tftp_root ).returns( sandbox.root )
        Nfsroot.stubs( :path ).returns( 'NFSROOT_PATH' )

        Nodes.stubs( :find ).with( 'NODE_NAME' ).returns( @node )

        lambda do
          Tftp.setup [ 'NODE_NAME' ], 'INSTALLER_NAME'
        end.should_not raise_error
      end
    end


    it 'should raise if installer is never built' do
      @tftp.stubs( :setup_tftpd )

      in_sandbox do | sandbox |
        build_statuses = Object.new
        build_statuses.stubs( :last_complete_build_status ).returns( 'never_built' )
        Installer.stubs( :new ).returns( build_statuses )

        Nodes.stubs( :find ).with( 'NODE_NAME' ).returns( @node )

        lambda do
          Tftp.setup [ 'NODE_NAME' ], 'INSTALLER_NAME'
        end.should raise_error( "Installer 'INSTALLER_NAME' is never built." )
      end
    end


    it 'should fail if TFTPD is not installed' do
      @tftp.stubs( :setup_pxe ).with( ['NODE_NAME' ], 'INSTALLER_NAME' )
      File.stubs( :exists? ).with( '/etc/init.d/tftpd-hpa' ).returns( false )

      lambda do
        Tftp.setup [ 'NODE_NAME' ], 'INSTALLER_NAME'
      end.should raise_error( 'tftpd-hpa package is not installed. Please install first.' )
    end


    it 'should start TFTPD if TFTPD is down' do
      @net_tftp.expects( :getbinary ).raises( Net::TFTPTimeout )
      @tftp.stubs( :setup_pxe )

      # expects
      @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa start' )

      lambda do
        Tftp.setup [ 'NODE_NAME' ], 'INSTALLER_NAME'
      end.should_not raise_error
    end


    it 'should start and stop TFTPD if failed to getginary' do
      # given
      @net_tftp.expects( :getbinary ).raises( 'getbinary failed' )
      @tftp.stubs( :setup_pxe )

      # expects
      @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa stop' )
      @tftp.expects( :sleep ).with( 2 )
      @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa start' )

      lambda do
        Tftp.setup [ 'NODE_NAME' ], 'INSTALLER_NAME'
      end.should_not raise_error
    end


    it 'should start and stop TFTPD if succeed to getbinary' do
      # given
      @net_tftp.expects( :getbinary )
      @tftp.stubs( :setup_pxe )

      # expects
      @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa stop' )
      @tftp.expects( :sleep ).with( 2 )
      @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa start' )

      lambda do
        Tftp.setup [ 'NODE_NAME' ], 'INSTALLER_NAME'
      end.should_not raise_error
    end
  end


  ################################################################################
  # Tftp.disable
  ################################################################################


  describe 'when disabling a node' do
    it 'should successfully generate TFTPD config file if the node found' do
      in_sandbox do | sandbox |
        Nodes.stubs( :find ).with( 'NODE_NAME' ).returns( @node )

        Configuration.stubs( :tftp_root ).returns( sandbox.root )

        Tftp.disable 'NODE_NAME'
        File.file?( File.join( sandbox.root, '/pxelinux.cfg/01-aa-bb-cc-dd-ee-ff' ) ).should be_true
      end
    end


    it 'should fail if the node is not added yet' do
      Nodes.stubs( :find ).with( 'NODE_NAME' ).returns( nil )

      lambda do
        Tftp.disable 'NODE_NAME'
      end.should raise_error( "Node 'NODE_NAME' is not added or enabled yet." )
    end
  end


  ################################################################################
  # Tftp.remove
  ################################################################################


  describe 'when removing a node' do
    it 'should succeed to remove PXE config file if node exists' do
      Nodes.stubs( :find ).with( 'NODE_NAME' ).returns( @node )
      FileUtils.stubs( :rm )

      lambda do
        Tftp.remove! 'NODE_NAME'
      end.should_not raise_error
    end


    it 'should fail to remove PXE config file it no such node found' do
      Nodes.stubs( :find ).with( 'NODE_NAME' ).returns( nil )

      lambda do
        Tftp.remove! 'NODE_NAME'
      end.should raise_error( "Node 'NODE_NAME' is not added or enabled yet.")
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
