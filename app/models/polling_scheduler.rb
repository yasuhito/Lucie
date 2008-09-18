class PollingScheduler
  def initialize installer
    @installer = installer
    @custom_polling_interval = nil
    @last_build_loop_error_source = nil
    @last_build_loop_error_time = nil
  end


  def run
    loop do
     begin
       @installer.build_if_necessary or check_build_request_until_next_polling
       clean_last_build_loop_error
       if @installer.config_modified?
         throw :reload_installer
       end
     rescue => e
       unless ( same_error_as_before( e ) and last_logged_less_than_an_hour_ago )
         log_error e
       end
       sleep Configuration.sleep_after_build_loop_error.to_i
     end
    end
  end


  def polling_interval= value
    begin
      value = value.to_i
    rescue
      raise "Polling interval value #{ value.inspect } could not be converted to a number of seconds"
    end
    if value < 5.seconds
      raise "Polling interval of #{ value } seconds is too small (min. 5 seconds)"
    end
    if value > 24.hours
      raise "Polling interval of #{ value } seconds is too big (max. 24 hours)"
    end
    @custom_polling_interval = value
  end


  def last_logged_less_than_an_hour_ago
    @last_build_loop_error_time and @last_build_loop_error_time >= 1.hour.ago
  end


  def polling_interval
    @custom_polling_interval or Configuration.default_polling_interval
  end


  def build_request_checking_interval
    return Configuration.build_request_checking_interval.to_i
  end


  def clean_last_build_loop_error
    @last_build_loop_error_source = @last_build_loop_error_time = nil
  end


  ################################################################################
  private
  ################################################################################


  def log_error error
    begin
      Lucie::Log.error error
    rescue
      STDERR.puts error.message
      STDERR.puts( error.backtrace.map do |l| "  #{ l }" end.join( "\n" ) )
    end
    @last_build_loop_error_source = error.backtrace.first
    @last_build_loop_error_time = Time.now
  end


  def same_error_as_before error
    @last_build_loop_error_source and ( error.backtrace.first == @last_build_loop_error_source )
  end


  def check_build_request_until_next_polling
    time_to_go = Time.now + polling_interval
    while Time.now < time_to_go
      @installer.build_if_requested
      sleep build_request_checking_interval
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
