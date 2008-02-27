class NodesController < ApplicationController
  layout 'default'


  def show
    @nodes = Nodes.load_all( params[ :id ] )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
