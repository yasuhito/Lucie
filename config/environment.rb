#
# Be sure to restart your web server when you modify this file.
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do | config |
  # Settings in config/environments/* take precedence over those specified here


  module ActiveRecord
    class ActiveRecordError
    end
    # just so that WhinyNil doesn't complain about const missing
    class Base
      # and just so that ActiveRecordStore can load (even though we dont use it either)
      def self.before_save(*args) end
      # and just so controller generator can do its stuff
      def self.pluralize_table_names() true; end
      # and just so that Dispatcher#reset_application works
      def self.reset_subclasses() end
      # and just so that Dispatcher#prepare_application works
      def self.verify_active_connections!() end
      # and just so that Dispatcher#reset_application! works so Webrick (unlike Mongrel) stops bombing out
      def self.clear_reloadable_connections!() end
      # and just so that benchmarking's render() works
      def self.connected?() false; end
      # and just so that Initializer#load_observers works
      def self.instantiate_observers; end
      # and just so that unit tests work
      def self.configurations; end
    end
  end

  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  config.frameworks -= [ :active_record, :action_web_service ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths << "#{RAILS_ROOT}/builder_plugins/installed"

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below

# custom MIME type for CCTray application
Mime::Type.register "application/cctray", :cctray


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
