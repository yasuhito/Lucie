class NodesController < ApplicationController
  layout 'default'


  def index
    @nodes = Nodes.load_all
  end
end