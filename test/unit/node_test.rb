require File.dirname( __FILE__ ) + '/../test_helper'


class NodeTest < Test::Unit::TestCase
  # [XXX] ノード名判定のテストを追加 (#74)
  def test_node_name
    # assert_equal 0, system( "#{ add_node } node000 -m 00:00:00:00:00:00" )
  end


  private


  def add_node
    return( File.dirname( __FILE__ ) + '/../../script/add_node' )
  end
end
