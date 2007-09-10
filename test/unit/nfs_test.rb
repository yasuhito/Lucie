require File.dirname( __FILE__ ) + '/../test_helper'


class NfsTest < Test::Unit::TestCase
  def test_setup___SUCCESS___
    nfs = Nfs.new
    Nfs.stubs( :new ).returns( nfs )
    nfs.stubs( :sh_exec )

    file = Object.new
    file.stubs( :puts )

    File.stubs( :copy ).with( '/etc/exports', '/etc/exports.orig' )
    File.stubs( :open ).with( '/etc/exports', 'w' ).yields( file )

    node = Object.new
    node.stubs( :name ).returns( 'NODE_NAME' )
    Nodes.stubs( :load_enabled ).with( 'INSTALLER_NAME' ).returns( [ node ] )

    assert_nothing_raised do
      Nfs.setup( 'INSTALLER_NAME' )
    end
  end
end
