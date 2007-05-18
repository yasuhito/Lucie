#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


#--
# XXX remane to LucieConfigTracker?
#++
class InstallerConfigTracker
  attr_accessor :central_config_file
  attr_accessor :central_mtime
  attr_accessor :local_config_file
  attr_accessor :local_mtime


  def initialize installer_path
    @central_config_file = File.expand_path( File.join( installer_path, 'work', 'lucie_config.rb' ) )
    @local_config_file = File.expand_path( File.join( installer_path, 'lucie_config.rb' ) )
    update_timestamps
  end


  def config_modified?
    old_timestamps = [ @central_mtime, @local_mtime ]
    update_timestamps
    [ @central_mtime, @local_mtime ] != old_timestamps
  end


  def update_timestamps
    @central_mtime = File.exist?( @central_config_file ) ? File.mtime( @central_config_file ) : nil
    @local_mtime = File.exist?( @local_config_file ) ? File.mtime( @local_config_file ) : nil
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
