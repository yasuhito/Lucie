require "configuration"
require "node"


class Nodes
  @@list = []


  def self.clear
    @@list = []
  end


  def self.add node, options = {}, messenger = nil
    self.new.__send__ :add, node, options, messenger
  end


  def self.remove! name, options = {}, messenger = $stdout
    @@list -= [ find( name ) ]
  end


  def self.find name
    @@list.each do | each |
      return each if each.name == name
    end
    nil
  end


  def self.load_all
    self.new.__send__ :load_all
  end


  def self.size
    load_all.size
  end


  def self.sort
    load_all.sort_by do | each |
      each.name
    end
  end


  ##############################################################################
  private
  ##############################################################################


  def load_all
    @@list
  end


  def add node, options, messenger
    @@list.delete_if do | each |
      each.name == node.name
    end
    @@list << node
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
