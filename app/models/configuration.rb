#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


class Configuration
  @default_page = {:controller => 'installers', :action => 'index'}
  @build_request_checking_interval = 5.seconds
  @dashboard_refresh_interval = 5.seconds
  @default_polling_interval = 10.seconds
  @installers_directory = File.expand_path( File.join( RAILS_ROOT, 'installers' ) )
  @sleep_after_build_loop_error = 30.seconds


  class << self
    # published configuration options (mentioned in config/site_config.rb.example)
    attr_accessor :default_polling_interval

    # non-published configuration options.
    attr_accessor :build_request_checking_interval
    attr_accessor :dashboard_refresh_interval
    attr_accessor :default_page
    attr_accessor :installers_directory
    attr_accessor :sleep_after_build_loop_error
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
