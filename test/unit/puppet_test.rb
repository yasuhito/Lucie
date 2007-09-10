require File.dirname( __FILE__ ) + '/../test_helper'


class PuppetTest < Test::Unit::TestCase
  include FileSandbox


  def test_setup___SUCCESS___
    puppet = Puppet.new
    Puppet.stubs( :new ).returns( puppet )
    puppet.stubs( :check_puppet_installed )
    puppet.stubs( :write_config )
    puppet.stubs( :restart_puppet )

    in_sandbox do | sandbox |
      assert_nothing_raised do
        Puppet.setup sandbox.root
      end
    end
  end


  def test_check_puppet_installed___FAIL___
    File.stubs( :exists? ).with( '/usr/sbin/puppetmasterd' ).returns( false )
    assert_raises( 'puppetmaster package is not installed. Please install first.' ) do
      Puppet.new.check_puppet_installed
    end
  end


  def test_write_config___SUCCESS___
    file = Object.new
    file.stubs( :puts )
    File.stubs( :open ).with( '/etc/puppet/puppetmasterd.conf', 'w' ).yields( file )
    File.stubs( :open ).with( '/etc/puppet/fileserver.conf', 'w' ).yields( file )
    assert_nothing_raised do
      Puppet.new.write_config
    end
  end


  def test_restart_puppet___SUCCESS___
    puppet = Puppet.new
    puppet.stubs( :sh_exec )
    Puppet.stubs( :new ).returns( puppet )

    assert_nothing_raised do
      Puppet.restart
    end
  end
end
