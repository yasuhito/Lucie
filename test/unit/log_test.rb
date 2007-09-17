require File.dirname( __FILE__ ) + '/../test_helper'


class LogTest < Test::Unit::TestCase
  def setup
    Lucie::Log.verbose = false
  end


  def test_verbose
    Lucie::Log.verbose = true
    assert Lucie::Log.verbose?

    Lucie::Log.verbose = false
    assert !Lucie::Log.verbose?
  end


  def test_event_returns_silently_when_debug_mode
    assert_nothing_raised do
      Lucie::Log.event 'DESCRIPTION', :debug
    end
  end


  def test_debug
    assert_nothing_raised do
      Lucie::Log.debug 'DESCRIPTION'
    end
  end


  def test_error
    Lucie::Log.verbose = true

    exception = Exception.new
    exception.stubs( :backtrace ).returns( [ 'DUMMY_BACKTRACE' ] )

    assert_nothing_raised do
      Lucie::Log.error exception
    end
  end


  def test_fatal
    assert_nothing_raised do
      Lucie::Log.fatal 'DESCRIPTION'
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
