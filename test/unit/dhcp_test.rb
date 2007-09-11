require File.dirname( __FILE__ ) + '/../test_helper'
require 'facter'


class DhcpTest < Test::Unit::TestCase
  include FileSandbox


  def test_setup___success__
    in_sandbox do | sandbox |
      sandbox.new :file => 'TEST_NODE/00:00:00:00:00:00', :with_content => ''
      sandbox.new :file => 'TEST_NODE/TEST_INSTALLER', :with_content => ''

      Configuration.stubs( :nodes_directory ).returns( sandbox.root )

      file = Object.new
      file.stubs( :puts )
      File.stubs( :copy ).with( '/etc/dhcp3/dhcpd.conf', '/etc/dhcp3/dhcpd.conf.orig' )
      File.stubs( :open ).with( '/etc/dhcp3/dhcpd.conf', 'w' ).yields( file )

      Facter.stubs( :value ).with( 'ipaddress' ).returns( '192.168.0.1' )
      Facter.stubs( :value ).with( 'domain' ).returns( 'FAKE.DOMAIN' )

      resolver = Object.new
      resolver.stubs( :getaddress ).with( 'TEST_NODE' ).returns( '192.168.1.100' )
      Resolv::Hosts.stubs( :new ).returns( resolver )

      dhcp = Dhcp.new
      Dhcp.stubs( :new ).returns( dhcp )
      dhcp.stubs( :sh_exec ).with( '/etc/init.d/dhcp3-server restart' )

      assert_nothing_raised do
        Dhcp.setup 'TEST_INSTALLER', '192.168.1.1', '255.255.255.0'
      end
    end
  end


  def test_domain_resolve_failure
    Facter.stubs( :value ).with( 'domain' ).returns( false )

    assert_raises( "Cannnot resolve Lucie server's domain name." ) do
      Dhcp.new.domain
    end
  end


  def test_ipaddress_resolve_failure
    Facter.stubs( :value ).with( 'ipaddress' ).returns( false )

    assert_raises( "Cannnot resolve Lucie server's IP address." ) do
      Dhcp.new.ipaddress
    end
  end


  def test_node_ipaddress_resolve_failure
    resolver = Object.new
    resolver.stubs( :getaddress ).with( 'NODE_NAME' ).returns( false )
    Resolv::Hosts.stubs( :new ).returns( resolver )

    assert_raises( "Cannnot resolve host 'NODE_NAME' IP address." ) do
      Dhcp.new.node_ipaddress 'NODE_NAME'
    end
  end
end
