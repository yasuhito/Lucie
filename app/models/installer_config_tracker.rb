class InstallerConfigTracker
  def initialize(installer_path)
    @central_config_file = File.expand_path(File.join(installer_path, 'work', 'installer.rb'))
    @local_config_file = File.expand_path(File.join(installer_path, 'installer.rb'))
    update_timestamps
  end


  def update_timestamps
    @central_mtime = File.exist?( @central_config_file ) ? File.mtime( @central_config_file ) : nil
    @local_mtime = File.exist?( @local_config_file ) ? File.mtime( @local_config_file ) : nil
  end
end
