require File.dirname( __FILE__ ) + '/../spec_helper'


describe PollingScheduler, 'when starting polling scheduler' do
  before :each do
    @installer = Object.new
    @polling_scheduler = PollingScheduler.new( @installer )
  end


  it 'should throw :reload_installer if configuration modified' do
    @installer.stubs( :build_if_necessary ).returns( true )
    @installer.stubs( :config_modified? ).returns( true )

    assert_throws( :reload_installer ) do
      @polling_scheduler.run
    end
  end


  it 'should log and record a new error' do
    dummy_error = 'DUMMY_ERROR'
    @installer.stubs( :build_if_necessary ).raises( dummy_error )

    # At first, error log should be empty
    @polling_scheduler.instance_variable_get( :@last_build_loop_error_source ).should be_nil
    @polling_scheduler.instance_variable_get( :@last_build_loop_error_time ).should be_nil

    Lucie::Log.expects( :error )

    # Raise dummy_error in order to quit from infinite loop
    Configuration.stubs( :sleep_after_build_loop_error ).raises( dummy_error )
    @polling_scheduler.run rescue nil

    # Last build error should be recorded
    @polling_scheduler.instance_variable_get( :@last_build_loop_error_source ).should_not be_nil
    @polling_scheduler.instance_variable_get( :@last_build_loop_error_time ).should_not be_nil
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
