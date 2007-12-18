require File.dirname( __FILE__ ) + '/../spec_helper'


describe Puppet, 'when calling Puppet.restart' do
  before :each do
    @puppet = Puppet.new
    Puppet.stubs( :new ).returns( @puppet )

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
    Puppet.restart

    # then
    verify_mocks
  end


  it 'should clean two certificates and restarts puppetmaster given 2 nodes are added' do
    # given
    @node_list.stubs( :list ).returns( [ stub_node( 'FOO' ), stub_node( 'BAR' ) ] )

    # expects
    @puppet.expects( :sh_exec ).with( 'puppetca --clean FOO.DOMAIN_NAME' )
    @puppet.expects( :sh_exec ).with( 'puppetca --clean BAR.DOMAIN_NAME' )
    @puppet.expects( :sh_exec ).with( '/etc/init.d/puppetmaster restart' )

    # when
    Puppet.restart

    # then
    verify_mocks
  end


  def stub_node name
    node = Object.new
    node.stubs( :name ).returns( name )
    node
  end
end
