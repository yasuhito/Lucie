require File.dirname( __FILE__ ) + '/../spec_helper'


describe PollingScheduler do
  before :each do
    @installer = Object.new
    @scheduler = PollingScheduler.new( @installer )
  end


  it 'should throw :reload_installer if configuration modified' do
    @installer.stubs( :build_if_necessary ).returns( true )
    @installer.stubs( :config_modified? ).returns( true )

    assert_throws( :reload_installer ) do
      @scheduler.run
    end
  end


  it 'should check build request until next polling' do
    @scheduler.expects( :polling_interval ).returns( 2.seconds )

    Time.expects( :now ).times( 4 ).returns( Time.at( 0 ), Time.at( 0 ), Time.at( 1 ), Time.at( 2 ) )
    @installer.expects( :build_if_requested ).times( 2 )
    Configuration.stubs( :build_request_checking_interval ).returns( 0 )

    @scheduler.__send__ :check_build_request_until_next_polling
  end


  it 'should check last logged less than an hour ago' do
    @scheduler.__send__( :last_logged_less_than_an_hour_ago ).should be_nil
  
    @scheduler.instance_eval( "@last_build_loop_error_time = DateTime.new( 2005, 1, 1 )" )

    time = DateTime.new( 2005, 1, 1 )

    Time.stubs( :now ).returns( time + 1.hour )
    @scheduler.__send__( :last_logged_less_than_an_hour_ago ).should be_true
    
    Time.stubs( :now ).returns( time + 1.hour + 1.second )
    @scheduler.__send__( :last_logged_less_than_an_hour_ago ).should be_false
  end


  describe 'when setting polling interval' do
    it 'should have a default value and can be overridden' do
      @scheduler.polling_interval.should == Configuration.default_polling_interval
      @scheduler.polling_interval = 1.minute
      @scheduler.polling_interval.should == 60
    end


    it 'should raise if polling_interval value exceeds its limits' do
      lambda do
        @scheduler.polling_interval = 5.seconds
      end.should_not raise_error

      lambda do 
        @scheduler.polling_interval = 4.seconds
      end.should raise_error( 'Polling interval of 4 seconds is too small (min. 5 seconds)' )

      lambda do
        @scheduler.polling_interval = 24.hours
      end.should_not raise_error

      lambda do
        @scheduler.polling_interval = 24.hours + 1.second
      end.should raise_error( 'Polling interval of 86401 seconds is too big (max. 24 hours)' )
    end


    it 'should raise if invalid polling interval set' do
      lambda do
        @scheduler.polling_interval = {}
      end.should raise_error( 'Polling interval value {} could not be converted to a number of seconds' )
    end
  end


  describe 'when a new error occured' do
    before :each do
      @dummy_error = 'DUMMY_ERROR'
      @installer.stubs( :build_if_necessary ).raises( @dummy_error )
    end


    it 'should log and record the error' do
      # At first, error log should be empty
      @scheduler.instance_variable_get( :@last_build_loop_error_source ).should be_nil
      @scheduler.instance_variable_get( :@last_build_loop_error_time ).should be_nil

      Lucie::Log.expects( :error )

      # Raise dummy_error in order to quit from infinite loop
      Configuration.stubs( :sleep_after_build_loop_error ).raises( @dummy_error )
      @scheduler.run rescue nil

      # Last build error should be recorded
      @scheduler.instance_variable_get( :@last_build_loop_error_source ).should_not be_nil
      @scheduler.instance_variable_get( :@last_build_loop_error_time ).should_not be_nil
    end


    it 'should emit error message to STDERR if default logger failed' do
      Lucie::Log.expects( :error ).raises @dummy_error

      STDERR.expects( :puts ).times( 2 )

      # Raise dummy_error in order to quit from infinite loop
      Configuration.stubs( :sleep_after_build_loop_error ).raises( @dummy_error )
      @scheduler.run rescue nil
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
