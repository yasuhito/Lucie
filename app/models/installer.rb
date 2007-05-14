class Installer
  def self.read dir, load_config = true
    @installer_in_the_works = Installer.new( File.basename( dir ) )
    begin
      @installer_in_the_works.load_config if load_config
      return @installer_in_the_works
    ensure
      @installer_in_the_works = nil
    end
  end


  attr_reader :name, :path


  def initialize name
    @name = name
    @path = File.join( Configuration.installers_directory, @name )
    @scheduler = PollingScheduler.new( self )
    @config_tracker = InstallerConfigTracker.new( self.path )
    @settings = ''
    @config_file_content = ''
    @error_message = ''
  end


  def path= value
    @config_tracker = InstallerConfigTracker.new( value )
    @path = value
  end
end
