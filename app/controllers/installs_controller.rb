class InstallsController < ApplicationController
  layout 'default'


  def show
    render :text => 'Node not specified', :status => 404 and return unless params[ :node ]

    @node = Nodes.find( params[ :node ] )
    render :text => "Node #{ params[ :node ].inspect } not found", :status => 404 and return unless @node

    @install = ( params[ :id ] ? Install.new( @node, params[ :id ] ) : nil )
    render :action => ( @install ? 'show' : 'no_installs_yet' )
  end
end
