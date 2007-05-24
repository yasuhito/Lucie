class Nodes
  def self.load_all
    Nodes.new( Configuration.nodes_directory ).load_all
  end


  def self.load_node dir
    node = Node.read( dir, load_config = false )
    node.path = dir
    return node
  end


  def initialize dir = Configuration.nodes_directory
    @dir = dir
    @list = []
  end


  def load_all
    @list = Dir[ "#{@dir}/*" ].find_all do | child |
      File.directory? child
    end.collect do | child |
      Nodes.load_node child
    end
    return self
  end


  def << node
    if @list.include?( node )
      raise "node named #{ node.name.inspect } already exists"
    end
    begin
      @list << node
      save_node node
      write_config_example node
      self
    rescue
      FileUtils.rm_rf "#{ @dir }/#{ node.name }"
      raise
    end
  end


  def save_node node
    node.path = File.join( @dir, node.name )
    FileUtils.mkdir_p node.path
  end


  def write_config_example node
  end
end
