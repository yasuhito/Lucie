class NodesController < ApplicationController
  layout 'default'


  def show
    @nodes = Nodes.load_all( params[ :id ] )

    respond_to do | format |
      format.html
      format.js { render :action => 'index_js' }
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
