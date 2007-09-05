class Nodes
  def self.summary installer_name
    nodes = load_node_list( installer_name )
    if nodes.size == 0
      return 'Never installed'
    else nodes.size > 0
      status = Hash.new( 0 )
      nodes.each do | each |
        status[ each.latest_install.status ] += 1
      end
      summary = []
      if status[ 'failure' ] > 0
        summary << "#{ status[ 'failure' ] } FAIL"
      end
      if status[ 'incomplete' ] > 0
        summary << "#{ status[ 'incomplete' ] } incomplete"
      end
      return 'OK' if summary == []
      return summary.join( ', ' )
    end
  end


  def self.load_node_list installer_name
    load_all.list.select do | each |
      each.installer_name == installer_name
    end
  end


  def self.load_all
    return Nodes.new( Configuration.nodes_directory ).load_all
  end


  def self.load_enabled installer_name
    Nodes.new( Configuration.nodes_directory ).load_enabled( installer_name )
  end


  def self.find node_name
    # TODO: sanitize node_name to prevent a query injection attack here
    path = File.join( Configuration.nodes_directory, node_name )
    unless File.directory?( path )
      return nil
    end
    load_node path
  end


  def self.load_node dir
    node = Node.read( dir, load_config = false )
    node.path = dir
    return node
  end


  attr_reader :dir
  attr_reader :list


  def initialize dir = Configuration.nodes_directory
    @dir = dir
    @list = []
  end


  def load_enabled installer_name
    @list = Dir[ "#{@dir}/*" ].find_all do | child |
      enabled = Dir[ child + "/*" ].find_all do | each |
        installer_name == File.basename( each )
      end
      ( not enabled.empty? ) and File.directory?( child )
    end.collect do | child |
      Nodes.load_node child
    end
    return self
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
      write_config node
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


  def write_config node
    mac_address_config = File.join( node.path, node.mac_address )

    FileUtils.touch mac_address_config
  end


  # delegate everything else to the underlying @list
  def method_missing method, *args, &block
    @list.send method, *args, &block
  end
end
