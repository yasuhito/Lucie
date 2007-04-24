#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


$LOAD_PATH.unshift( '../../lib' ) if /\.rb$/=~ __FILE__


require 'pbar/progress'
require 'test/unit'


class TC_Progress < Test::Unit::TestCase
  def setup
    @progress = Progress.new
  end


  def test_version
    assert_equal '0.6.3', Progress::VERSION
  end

  
  def test_activity_mode?
    assert_equal false, @progress.activity_mode?
  end


  def test_activity_mode=()
    assert_equal false, @progress.activity_mode = false
    assert @progress.activity_mode = true
    assert_raises( TypeError ) do
      @progress.activity_mode = 'String'
    end
  end


  def test_set_activity_mode
    assert_kind_of Progress, @progress.set_activity_mode( true )
    assert_raises( TypeError ) do
      @progress.set_activity_mode( 'String' )
    end
  end


  def test_show_text?
    assert_equal false, @progress.show_text?
  end


  def test_show_text=()
    assert_equal false, @progress.show_text = false
    assert @progress.show_text = true
    assert_raises( TypeError ) do
      @progress.show_text = 'String'
    end
  end


  def test_set_show_text
    assert_equal false, @progress.set_show_text( false )
    assert @progress.set_show_text( true )
    assert_raises( TypeError ) do
      @progress.set_show_text( 'String' )
    end
  end
end


### Local variables:
### mode: Ruby
### coding: euc-jp-unix
### indent-tabs-mode: nil
### End:
