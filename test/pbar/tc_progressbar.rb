#!/usr/bin/env ruby
#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


if /\.rb$/=~ __FILE__
  $LOAD_PATH.unshift( '../../lib' )
end


require 'pbar/progressbar'
require 'test/unit'


class TC_ProgressBar < Test::Unit::TestCase
  def setup
    @pbar = ProgressBar.new
  end


  def teardown
    STDERR.puts
  end


  def test_version
    assert_equal '0.6.3', ProgressBar::VERSION
  end


  def test_pulse
    200.times do
      assert_kind_of ProgressBar, @pbar.pulse
      sleep 0.01
    end
  end


  def test_pulse_with_text
    @pbar.show_text = true
    @pbar.text = 'test (pulse)'
    200.times do
      assert_kind_of ProgressBar, @pbar.pulse
      sleep 0.01
    end
  end


  def test_pulse2_with_text
    @pbar.show_text = true
    @pbar.pulse_step = 0.02
    @pbar.text = 'test (pulse, stepsize x2)'
    200.times do
      assert_kind_of ProgressBar, @pbar.pulse
      sleep 0.01
    end
  end


  def test_fraction=()
    while @pbar.fraction <= 1.0
      new_val = @pbar.fraction + 0.01
      assert_equal new_val, @pbar.fraction = new_val
      sleep 0.01
    end
  end


  def test_fraction_with_text
    @pbar.show_text = true
    @pbar.text = 'test (fraction=)'
    while @pbar.fraction <= 1.0
      new_val = @pbar.fraction + 0.01
      assert_equal new_val, @pbar.fraction = new_val
      sleep 0.01
    end
  end


  def test_fraction_right2left
    @pbar.show_text = true
    @pbar.text = 'test (fraction=)'
    @pbar.orientation = ProgressBar::RIGHT_TO_LEFT
    while @pbar.fraction <= 1.0
      new_val = @pbar.fraction + 0.01
      assert_equal new_val, @pbar.fraction = new_val
      sleep 0.01
    end
  end


  def test_set_fraction
    while @pbar.fraction <= 1.0
      new_val = @pbar.fraction + 0.01
      assert_kind_of ProgressBar, @pbar.set_fraction( new_val )
      sleep 0.01
    end
  end


  def test_set_fraction_with_text
    @pbar.show_text = true
    @pbar.text = 'test (set_fraction())'
    while @pbar.fraction <= 1.0
      new_val = @pbar.fraction + 0.01
      assert_kind_of ProgressBar, @pbar.set_fraction( new_val )
      sleep 0.01
    end
  end


  def test_set_fraction_right_to_left
    @pbar.show_text = true
    @pbar.text = 'test (set_fraction())'
    @pbar.orientation = ProgressBar::RIGHT_TO_LEFT
    while @pbar.fraction <= 1.0
      new_val = @pbar.fraction + 0.01
      assert_kind_of ProgressBar, @pbar.set_fraction( new_val )
      sleep 0.01
    end
  end
end


### Local variables:
### mode: Ruby
### coding: euc-jp-unix
### indent-tabs-mode: nil
### End:
