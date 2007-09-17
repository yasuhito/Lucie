require File.dirname( __FILE__ ) + '/../test_helper'
require 'lib/platform'


class PlatformTest < Test::Unit::TestCase
  def test_family___success___
    Config::CONFIG.stubs( :[] ).with( 'target_os' ).returns( 'linux' )
    assert_equal 'linux', Platform.family
  end


  def test_family___fail___
    Config::CONFIG.stubs( :[] ).with( 'target_os' ).returns( 'UNKNOWN_OS' )
    assert_raises( 'Unknown OS: UNKNOWN_OS' ) do
      Platform.family
    end
  end


  def test_user
    assert_nothing_raised do
      Platform.user
    end
  end


  def test_prompt
    Dir.stubs( :pwd ).returns( '/CWD' )
    assert_match /\A\/CWD/, Platform.prompt
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:

