class Configuration
  @installers_directory = File.expand_path( File.join( RAILS_ROOT, 'installers' ) )


  class << self
    # non-published configuration options.
    attr_accessor :installers_directory
  end
end
