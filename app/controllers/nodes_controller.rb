class NodesController < ApplicationController
  layout 'default'


  def index
    @nodes = Nodes.load_all
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
