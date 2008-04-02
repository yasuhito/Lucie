require File.dirname( __FILE__ ) + '/../spec_helper'


describe PuppetController, 'when calling PuppetController.setup' do
  it 'should setup puppet' do
    file_stub = StringIO.new( '' )
    puppet = PuppetController.new
    PuppetController.stubs( :new ).returns( puppet )


    # expects
    File.expects( :exists? ).with( '/usr/sbin/puppetmasterd' ).returns( true )
    File.expects( :open ).with( '/etc/puppet/puppetmasterd.conf', 'w' ).yields( file_stub )
    File.expects( :open ).with( '/etc/puppet/fileserver.conf', 'w' ).yields( file_stub )
    puppet.expects( :restart_puppet )

    # when
    PuppetController.setup 'LOCAL_CHECKOUT_DIR'

    # then
    verify_mocks
  end


  it 'should raise if puppet is not installed' do
    # expects
    File.expects( :exists? ).with( '/usr/sbin/puppetmasterd' ).returns( false )

    # when
    lambda do
      PuppetController.setup 'LOCAL_CHECKOUT_DIR'
      # then
    end.should raise_error( RuntimeError, 'puppetmaster package is not installed. Please install first.' )
    verify_mocks
  end
end


describe PuppetController, 'when calling PuppetController.restart' do
  before :each do
    @puppet = PuppetController.new
    PuppetController.stubs( :new ).returns( @puppet )

    @node_list = Object.new
    Nodes.stubs( :load_all ).returns( @node_list )

    Facter.stubs( :value ).with( 'domain' ).returns( 'DOMAIN_NAME' )
  end


  it 'should restart puppetmaster given there is no node' do
    # given
    @node_list.stubs( :list ).returns( [ ] )

    # expects
    @puppet.expects( :sh_exec ).with( '/etc/init.d/puppetmaster restart' )

    # when
    PuppetController.restart

    # then
    verify_mocks
  end


  it 'should clean two certificates and restarts puppetmaster given 2 nodes are added' do
    # given
    @node_list.stubs( :list ).returns( [ stub_node( 'FOO' ), stub_node( 'BAR' ) ] )

    # expects
    @puppet.expects( :sh_exec ).with( 'puppetca --clean FOO.DOMAIN_NAME BAR.DOMAIN_NAME || true' )
    @puppet.expects( :sh_exec ).with( '/etc/init.d/puppetmaster restart' )

    # when
    PuppetController.restart

    # then
    verify_mocks
  end


  def stub_node name
    node = Object.new
    node.stubs( :name ).returns( name )
    node
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
