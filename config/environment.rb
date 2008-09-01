# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# Lucie: this line should stay comented out
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join( File.dirname( __FILE__ ), 'boot' )

Rails::Initializer.run do | config |
  # Settings in config/environments/* take precedence over those specified here

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  config.frameworks -= [ :active_record, :action_web_service ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths << "#{ RAILS_ROOT }/lib/builder_plugins"
  config.load_paths << "#{ RAILS_ROOT }/builder_plugins/installed"
  config.load_paths << "#{ RAILS_ROOT }/vendor/ruby-ifconfig-1.2/lib"
  config.load_paths << "#{ RAILS_ROOT }/vendor/file_sandbox/lib"

  # See Rails::Configuration for more options
end

# Include your application configuration below

# custom MIME type for CCTray application
Mime::Type.register "application/cctray", :cctray


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
