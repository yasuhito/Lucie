require File.dirname(__FILE__) + '/../test_helper'


class SubversionLogParserTest < Test::Unit::TestCase
  def test_can_parse_LOG_WITH_NO_OPTIONAL_VALUES
    expected_result = [ Revision.new( 359, nil, nil, nil, [] ) ]
                                  
    assert_equal expected_result, parse_log( "<log><logentry revision='359'/></log>" )
  end


  def parse_log(log_entry)
    SubversionLogParser.new.parse_log(log_entry.split("\n"))
  end
end
