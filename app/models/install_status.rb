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
