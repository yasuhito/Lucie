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
    assert_nothing_raised do
      Lucie::Log.error 'DESCRIPTION'
    end
  end


  def test_fatal
    assert_nothing_raised do
      Lucie::Log.fatal 'DESCRIPTION'
    end
  end
end

