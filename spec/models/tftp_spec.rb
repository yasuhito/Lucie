require File.dirname( __FILE__ ) + '/../spec_helper'


describe Tftp, 'when calling Tftp.setup' do
  it 'should succeed' do
    tftp = Tftp.new
    Tftp.stubs( :new ).returns( tftp )

    # expects
    tftp.expects( :setup_pxe ).with( 'NODE_NAME', 'INSTALLER_NAME' )
    tftp.expects :setup_tftpd

    # when
    lambda do
      Tftp.setup 'NODE_NAME', 'INSTALLER_NAME'
      # then
    end.should_not raise_error
  end
end


describe Tftp, 'when calling Tftp.disable' do
  it 'should succeed' do
    tftp = Tftp.new
    Tftp.stubs( :new ).returns( tftp )

    # expects
    tftp.expects( :disable_pxe ).with( 'NODE_NAME' )
    tftp.expects :setup_tftpd

    # when
    lambda do
      Tftp.disable 'NODE_NAME'

      # then
    end.should_not raise_error
  end
end


describe Tftp, 'when calling Tftp.setup_pxe' do
  include FileSandbox


  it 'should succeed' do
    in_sandbox do | sandbox |
      node = Object.new
      node.stubs( :name ).returns( 'NODE_NAME' )
      node.stubs( :mac_address ).returns( 'AA:BB:CC:DD:EE:FF' )
      Nodes.stubs( :find ).with( 'NODE_NAME' ).returns( node )

      Configuration.stubs( :tftp_root ).returns( sandbox.root )
      Nfsroot.stubs( :path ).returns( 'NFSROOT_PATH' )

      lambda do
        Tftp.new.setup_pxe 'NODE_NAME', 'INSTALLER_NAME'
      end.should_not raise_error

      File.file?( File.join( sandbox.root, '/pxelinux.cfg/01-aa-bb-cc-dd-ee-ff' ) ).should be_true
    end
  end


  it 'should fail if no node is added or enabled yet' do
    Nodes.stubs( :load_enabled ).with( 'INSTALLER_NAME' ).returns( [] )

    lambda do
      Tftp.new.setup_pxe 'NODE_NAME', 'INSTALLER_NAME'
    end.should raise_error( "Node 'NODE_NAME' is not added or enabled yet." )
  end
end


describe Tftp, 'when calling Tftp.disable_pxe' do
  it 'should succeed' do
    in_sandbox do | sandbox |
      node = Object.new
      node.stubs( :name ).returns( 'NODE_NAME' )
      node.stubs( :mac_address ).returns( 'AA:BB:CC:DD:EE:FF' )
      Nodes.stubs( :find ).with( 'NODE_NAME' ).returns( node )

      Configuration.stubs( :tftp_root ).returns( sandbox.root )

      lambda do
        Tftp.new.disable_pxe 'NODE_NAME'
      end.should_not raise_error

      File.file?( File.join( sandbox.root, '/pxelinux.cfg/01-aa-bb-cc-dd-ee-ff' ) ).should be_true
    end
  end
end


describe Tftp, 'when calling Tftp.setup_tftpd' do
  before( :each ) do
    @tftp = Tftp.new

    @net_tftp = Object.new
    Net::TFTP.stubs( :open ).returns( @net_tftp )

    file = Object.new
    file.stubs( :puts )
    File.stubs( :open ).with( '/etc/default/tftpd-hpa', 'w' ).yields( file )
  end


  it 'should start tftpd if timeouted to getbinary (tftpd is DOWN)' do
    # given
    @net_tftp.expects( :getbinary ).raises( Net::TFTPTimeout )

    # expects
    @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa start' )

    # when
    lambda do
      @tftp.setup_tftpd
    end.should_not raise_error
  end


  it 'should stop and start tftpd if failed to getbinary (tftpd is UP)' do
    # given
    @net_tftp.expects( :getbinary ).raises( 'getbinary failed' )

    # expects
    @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa stop' )
    @tftp.expects( :sleep ).with( 2 )
    @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa start' )

    # when
    lambda do
      @tftp.setup_tftpd
    end.should_not raise_error
  end


  it 'should stop and start tftpd if succeeded to getbinary (tftpd is UP)' do
    # given
    @net_tftp.expects( :getbinary )

    # expects
    @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa stop' )
    @tftp.expects( :sleep ).with( 2 )
    @tftp.expects( :sh_exec ).with( '/etc/init.d/tftpd-hpa start' )

    # when
    lambda do
      @tftp.setup_tftpd
    end.should_not raise_error
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
