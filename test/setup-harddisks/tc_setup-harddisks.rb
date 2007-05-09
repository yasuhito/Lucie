#
# $Id$
#
# Author::   Yasuhito Takamiya (mailto:takamiya@matsulab.is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

$LOAD_PATH.unshift './lib'

require 'test/unit'
require 'lucie/setup-harddisks/setup-harddisks'

include Lucie::SetupHarddisks

class TC_SetupHardDisk < Test::Unit::TestCase
  public
  def test_initialize
    assert_raises(NoMethodError) {
      app = SetupHarddisks.new
    }
    assert_nothing_raised {
      app = SetupHarddisks.instance
    }
  end
end

### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
