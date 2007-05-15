#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


class Configuration
  @installers_directory = File.expand_path( File.join( RAILS_ROOT, 'installers' ) )
  @dashboard_refresh_interval = 5.seconds

  class << self
    # non-published configuration options.
    attr_accessor :installers_directory
    attr_accessor :dashboard_refresh_interval
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
