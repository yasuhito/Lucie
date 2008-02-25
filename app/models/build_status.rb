class BuildStatus
  def initialize artifacts_directory
    @artifacts_directory = artifacts_directory
  end


  def start!
    remove_status_file
    touch_status_file 'incomplete'
  end


  def succeeded?
    return( read_latest_status == 'success' )
  end


  def succeed! elapsed_time
    remove_status_file
    touch_status_file "success.in#{ elapsed_time }s"
  end


  def failed?
    return( read_latest_status == 'failed' )
  end


  def fail! elapsed_time, error_message = nil
    remove_status_file
    touch_status_file "failed.in#{ elapsed_time }s", error_message
  end


  def never_built?
    return( read_latest_status == 'never_built' )
  end


  def incomplete?
    return( read_latest_status == 'incomplete' )
  end


  def elapsed_time
    file = status_file
    return match_elapsed_time( File.basename( file ) )
  end


  def elapsed_time_in_progress
    if incomplete?
      return ( Time.now - created_at ).ceil
    end
    return nil
  end


  def match_elapsed_time file_name
    match = /\Abuild_status\.[^\.]+\.in(\d+)s\Z/.match( file_name )
    if !match or !$1
      raise 'Could not parse elapsed time.'
    end
    return $1.to_i
  end


  def to_s
    return read_latest_status.to_s
  end


  def status_file
    return Dir[ "#{ @artifacts_directory }/build_status.*" ].first
  end


  def created_at
    if file = status_file
      return File.mtime( file )
    end
    return nil
  end


  def timestamp
    build_dir_mtime = File.mtime( @artifacts_directory )
    begin
      build_log_mtime = File.mtime( "#{ @artifacts_directory }/build.log" )
    rescue
      return build_dir_mtime
    end
    if build_log_mtime > build_dir_mtime
      return build_log_mtime
    end
    return build_dir_mtime
  end


  private


  def touch_status_file status, error_message=nil
    filename = "#{ @artifacts_directory }/build_status.#{ status }"
    FileUtils.touch filename
    if error_message
      File.open( filename, 'w' ) do | file |
        file.write error_message
      end
    end
  end


  def remove_status_file
    FileUtils.rm_f Dir[ "#{ @artifacts_directory }/build_status.*" ]
  end


  def read_latest_status
    file = status_file
    if file
      return match_status( File.basename( file ) ).downcase
    end
    return 'never_built'
  end


  def match_status file_name
    return /\Abuild_status\.([^\.]+)(\..+)?/.match( file_name )[ 1 ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
