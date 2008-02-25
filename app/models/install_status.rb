class InstallStatus
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


  def incomplete?
    return( read_latest_status == 'incomplete' )
  end


  def read_latest_status
    file = status_file
    if file
      return match_status( File.basename( file ) ).downcase
    end
    return 'never_installed'
  end


  def status_file
    return Dir[ "#{ @artifacts_directory }/install_status.*" ].first
  end


  def match_status file_name
    return /\Ainstall_status\.([^\.]+)(\..+)?/.match( file_name )[ 1 ]
  end


  def to_s
    return read_latest_status
  end


  def timestamp
    install_dir_mtime = File.mtime( @artifacts_directory )
    begin
      install_log_mtime = File.mtime( "#{ @artifacts_directory }/install.log" )
    rescue
      return install_dir_mtime
    end
    if install_log_mtime > install_dir_mtime
      return install_log_mtime
    end
    return install_dir_mtime
  end


  def elapsed_time
    file = status_file
    return match_elapsed_time( File.basename( file ) )
  end


  def match_elapsed_time file_name
    match = /\Ainstall_status\.[^\.]+\.in(\d+)s\Z/.match( file_name )
    if !match or !$1
      raise 'Could not parse elapsed time.'
    end
    return $1.to_i
  end


  private


  def touch_status_file status, error_message = nil
    filename = "#{ @artifacts_directory }/install_status.#{ status }"
    FileUtils.touch filename
    if error_message
      File.open( filename, 'w' ) do | file |
        file.write error_message
      end
    end
  end


  def remove_status_file
    FileUtils.rm_f Dir[ "#{ @artifacts_directory }/install_status.*" ]
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
