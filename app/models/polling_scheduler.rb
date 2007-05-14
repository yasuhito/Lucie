class PollingScheduler
  def initialize installer
    @installer = installer
    @custom_polling_interval = nil
    @last_build_loop_error_source = nil
    @last_build_loop_error_time = nil
  end
end
