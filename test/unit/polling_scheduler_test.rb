#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


require File.dirname( __FILE__ ) + '/../test_helper'


class PollingSchedulerTest < Test::Unit::TestCase
  def setup
    @mock_installer = Object.new
    @scheduler = PollingScheduler.new( @mock_installer )
  end


  def test_polling_interval_default_value_and_overriding
    assert_equal Configuration.default_polling_interval, @scheduler.polling_interval
    @scheduler.polling_interval = 1.minute
    assert_equal 60, @scheduler.polling_interval
  end


  def test_polling_interval_limits
    assert_nothing_raised do
      @scheduler.polling_interval = 5.seconds
    end

    assert_raises( 'Polling interval of 4 seconds is too small (min. 5 seconds)' ) do
      @scheduler.polling_interval = 4.seconds
    end

    assert_nothing_raised do
      @scheduler.polling_interval = 24.hours
    end

    assert_raises( 'Polling interval of 86401 seconds is too big (max. 24 hours)' ) do
      @scheduler.polling_interval = 24.hours + 1.second
    end
  end


  def test_invalid_polling_interval_raises_exception
    assert_raises( 'Polling interval value {} could not be converted to a number of seconds' ) do
      @scheduler.polling_interval = {}
    end
  end


  def test_last_logged_less_than_an_hour_ago
    assert !@scheduler.last_logged_less_than_an_hour_ago
  
    @scheduler.instance_eval( "@last_build_loop_error_time = DateTime.new( 2005, 1, 1 )" )

    time = DateTime.new( 2005, 1, 1 )

    Time.stubs( :now ).returns( time + 1.hour )
    assert @scheduler.last_logged_less_than_an_hour_ago
    
    Time.stubs( :now ).returns( time + 1.hour + 1.second )
    assert !@scheduler.last_logged_less_than_an_hour_ago
  end


  def test_check_build_request_until_next_polling
    @scheduler.expects( :polling_interval ).returns( 2.seconds )
    @scheduler.stubs( :build_request_checking_interval ).returns( 0 )
    Time.expects( :now ).times( 4 ).returns( Time.at( 0 ), Time.at( 0 ), Time.at( 1 ), Time.at( 2 ) )
    @mock_installer.expects( :build_if_requested ).times( 2 )

    @scheduler.check_build_request_until_next_polling
  end


  def test_should_return_flag_to_reload_installer_if_configurations_modified
    @scheduler.expects( :check_build_request_until_next_polling ).returns( false )
    @mock_installer.expects( :build_if_necessary ).returns( nil )
    @mock_installer.expects( :config_modified? ).returns( true ) 

    assert_throws( :reload_installer ) do
      @scheduler.run
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
