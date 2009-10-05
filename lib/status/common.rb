require "lucie/utils"


module Status
  class Common
    include Lucie::Utils


    def self.base_name name # :nodoc:
      module_eval %-
        @@base_name = name
      -
    end


    def initialize path, options, messenger
      @path = path
      @options = options
      @messenger = messenger
    end

    
    def to_s
      read_latest_status.to_s
    end


    ############################################################################
    # Status setters
    ############################################################################


    def start!
      start_timer
      remove_old_status_file
      touch_status_file "incomplete"
    end


    def succeed!
      elapsed = stop_timer
      remove_old_status_file
      touch_status_file "success.in#{ elapsed }s"
    end


    def fail!
      elapsed = stop_timer
      remove_old_status_file
      touch_status_file "failed.in#{ elapsed }s"
    end


    ############################################################################
    # Status getters
    ############################################################################


    def succeeded?
      read_latest_status == 'success'
    end


    def failed?
      read_latest_status == 'failed'
    end


    def incomplete?
      read_latest_status == 'incomplete'
    end


    def elapsed_time
      file = status_file
      match_elapsed_time( File.basename( file ) )
    end


    def elapsed_time_in_progress
      if incomplete?
        ( Time.now - created_at ).ceil
      else
        nil
      end
    end


    ##############################################################################
    private
    ##############################################################################


    def base_name
      instance_eval do | obj |
        obj.class.__send__ :class_variable_get, :@@base_name
      end
    end


    def status_file
      Dir[ "#{ @path }/#{ base_name }.*" ].first
    end


    def match_status file_name
      return /\A#{ base_name }\.([^\.]+)(\..+)?/.match( file_name )[ 1 ]
    end


    def match_elapsed_time file_name
      match = /\A#{ base_name }\.[^\.]+\.in(\d+)s\Z/.match( file_name )
      if !match or !$1
        raise 'Could not parse elapsed time.'
      end
      return $1.to_i
    end


    def read_latest_status
      return match_status( File.basename( status_file ) ).downcase if status_file
      nil
    end


    def touch_status_file status
      filename = File.join( @path, "#{ base_name }.#{ status }" )
      touch filename, @options, @messenger
    end


    def remove_old_status_file
      Dir[ File.join( @path, "#{ base_name }.*" ) ].each do | each |
        rm_f each, @options, @messenger
      end
    end


    ############################################################################
    # Timer operations
    ############################################################################


    def start_timer
      @time = Time.now
    end


    def stop_timer
      ( Time.now - @time ).ceil
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
