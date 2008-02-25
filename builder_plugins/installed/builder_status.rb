#
# this plugin allows the dashboard to know each builder's status and report it
#
# (this plugin is built in and needs no customization)
#
class BuilderStatus
  
  def initialize(installer)
    @installer = installer
  end

  def status
    if builder_down?
      'builder_down'
    else
      case _status = read_status
      when 'checking_for_modifications', 'sleeping'
        @installer.build_requested? ? 'build_requested' : _status
      else
        _status
      end
    end
  end

  def fatal?
    status == 'svn_error'
  end
  
  def error_message
    File.open(existing_status_file){|f| f.read} rescue ""
  end
  
  def build_initiated
    set_status 'building'
  end

  def build_finished(build)
    set_status 'sleeping'
  end

  def sleeping
    set_status 'sleeping'
  end

  def polling_source_control
    set_status 'checking_for_modifications'
  end

  def build_loop_failed(e)
    if e.is_a?(BuilderError)
      set_status e.status, e.message
    else
      set_status 'error'
    end
  end
  
  private
  def existing_status_file
    Dir["#{@installer.path}/builder_status.*"].first
  end
  
  def read_status
    if existing_status_file
      File.basename(existing_status_file)[15..-1]
    else
      'sleeping'
    end
  end

  def set_status(status, message = nil)
    FileUtils.rm_f(Dir["#{@installer.path}/builder_status.*"])
    status_file = "#{@installer.path}/builder_status.#{status}"
    FileUtils.touch(status_file)
    File.open(status_file, "w"){|f| f.write message } if message
  end

  def builder_down?
    !InstallerBlocker.blocked?(@installer)
  end

end

Installer.plugin :builder_status


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
