require "lucie/utils"


module Status
  #
  # An error raised by Status::* classes.
  #
  class StatusError < StandardError; end


  #
  # A base class for Status::* classes.
  #
  class Common
    include Lucie::Utils

    attr_reader :path


    def self.base_name name # :nodoc:
      module_eval %-
        @@base_name = name
      -
    end


    def initialize path, debug_options = {}
      @path = path
      @debug_options = debug_options
      @messenger = debug_options[ :messenger ]
    end

    
    def to_s
      read_latest_status.to_s
    end


    def update message
      write_status_file "incomplete", message
    end


    def read
      Dir[ File.join( @path, "#{ base_name }.*" ) ].each do | each |
        return IO.read( each )
      end
      nil
    end


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
      raise Status::StatusError, "Could not find status file" unless file
      match_elapsed_time( File.basename( file ) )
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
      raise StatusError, "Could not parse elapsed time." if !match or !$1
      return $1.to_i
    end


    def read_latest_status
      file = status_file
      return match_status( File.basename( file ) ).downcase if file
      nil
    end


    def write_status_file status, message
      filename = File.join( @path, "#{ base_name }.#{ status }" )
      mkdir_p( @path, @debug_options ) unless FileTest.directory?( @path )
      write_file filename, message, @debug_options
    end


    def touch_status_file status
      filename = File.join( @path, "#{ base_name }.#{ status }" )
      mkdir_p( @path, @debug_options ) unless FileTest.directory?( @path )
      touch filename, @debug_options
    end


    def remove_old_status_file
      Dir[ File.join( @path, "#{ base_name }.*" ) ].each do | each |
        rm_f each, @debug_options
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
