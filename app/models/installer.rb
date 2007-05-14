#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


class Installer
  def self.read dir, load_config = true
    @installer_in_the_works = Installer.new( File.basename( dir ) )
    begin
      if load_config
        @installer_in_the_works.load_config
      end
      return @installer_in_the_works
    ensure
      @installer_in_the_works = nil
    end
  end


  attr_reader :name, :path
  attr_accessor :scheduler


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


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
