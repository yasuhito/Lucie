require File.dirname( __FILE__ ) + '/../spec_helper'


describe NodesController do
  it 'should route /nodes/show/[INSTALLER_NAME] to /nodes/[INSTALLER_NAME]' do
    route_for( :controller => 'nodes', :action => 'show', :id => 'TEST_INSTALLER' ).should == '/nodes/TEST_INSTALLER'
  end


  it 'should assign nodes and render nodes/show if nodes found' do
    # expects
    Nodes.expects( :load_all ).with( 'TEST_INSTALLER' ).returns( [ 'DUMMY_NODE', 'DUMMY_NODE', 'DUMMY_NODE' ] )

    # when
    get 'show', :id => 'TEST_INSTALLER'

    # then
    response.should be_success
    response.should render_template( 'nodes/show' )
    assigns[ :nodes ].should == [ 'DUMMY_NODE', 'DUMMY_NODE', 'DUMMY_NODE' ]
  end


  it 'should assign nodes and render nodes/_no_nodes if no nodes' do
    # expects
    Nodes.expects( :load_all ).with( 'TEST_INSTALLER' ).returns( [ ] )

    # when
    get 'show', :id => 'TEST_INSTALLER'

    # then
    response.should be_success
    controller.expect_render  :partial => 'no_nodes'
    assigns[ :nodes ].should == [ ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
