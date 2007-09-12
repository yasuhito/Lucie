require File.dirname( __FILE__ ) + '/../test_helper'


class TftpTest < Test::Unit::TestCase
  include FileSandbox


  def test_setup___SUCCESS___
    tftp = Tftp.new
    Tftp.stubs( :new ).returns( tftp )
    tftp.stubs( :setup_pxe )
    tftp.stubs( :setup_tftpd )

    Tftp.setup 'NODE_NAME', 'INSTALLER_NAME'
  end


  def test_setup_pxe___SUCCESS___
    in_sandbox do | sandbox |
      node = Object.new
      node.stubs( :name ).returns( 'NODE_NAME' )
      node.stubs( :mac_address ).returns( 'AA:BB:CC:DD:EE:FF' )
      Nodes.stubs( :load_enabled ).with( 'INSTALLER_NAME' ).returns( [ node ] )

      tftp = Tftp.new
      tftp.stubs( :installer_name ).returns( 'INSTALLER_NAME' )
      tftp.stubs( :node_name ).returns( 'NODE_NAME' )

      Configuration.stubs( :tftp_root ).returns( sandbox.root )

      assert_nothing_raised do
        tftp.setup_pxe
      end
      assert File.file?( File.join( sandbox.root, '/pxelinux.cfg/01-aa-bb-cc-dd-ee-ff' ) )
    end
  end


  def test_setup_pxe___FAIL___
    tftp = Tftp.new
    tftp.stubs( :node_name ).returns( 'NODE_NAME' )
    tftp.stubs( :installer_name ).returns( 'INSTALLER_NAME' )
    Nodes.stubs( :load_enabled ).with( 'INSTALLER_NAME' ).returns( [] )

    assert_raises( "Node 'NODE_NAME' is not added or enabled yet." ) do
      tftp.setup_pxe
    end
  end


  def test_setup_tftpd___SUCCESS___
    tftp = Tftp.new
    file = Object.new
    file.stubs( :puts )
    File.stubs( :open ).with( '/etc/default/tftpd-hpa', 'w' ).yields( file )
    tftp.stubs( :sh_exec )

    assert_nothing_raised do
      tftp.setup_tftpd
    end
  end
end
