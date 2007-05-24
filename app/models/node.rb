class Node
  attr_reader :name
  attr_reader :path


  def self.read dir, load_config = true
    @node_in_the_works = Node.new( File.basename( dir ) )
    begin
      if load_config
        @node_in_the_works.load_config
      end
      return @node_in_the_works
    ensure
      @node_in_the_works = nil
    end
  end


  def initialize name
    @name = name
    @path = File.join( Configuration.nodes_directory, @name )
  end


  def == another
    return( another.is_a?( Node ) and another.name == self.name )
  end


  # XXX needs NodeConfigTracker?
  def path= value
    # @config_tracker = NodeConfigTracker.new( value )
    @path = value
  end
end
