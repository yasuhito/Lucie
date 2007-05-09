#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

$LOAD_PATH.unshift './lib'

require 'lucie/setup-harddisks/command-line-options'
require 'lucie/setup-harddisks/swap'
require 'test/unit'

include Lucie::SetupHarddisks

class TC_Swap < Test::Unit::TestCase
  public
  def setup
    $commandline_options = CommandLineOptions.instance
    @fs = Swap.new
    @fs.format_options += [ "-c"]
    @fs.mount_options += [ "-v" ]
  end
  
  public
  def test_name
    assert_equal( "swap", @fs.fs_type )
  end
  
  public
  def test_check_programs
    assert_equal( "mkswap", @fs.format_program )
    assert_equal( "swapon", @fs.mount_program )
  end
  
  public
  def test_fsck_enabled
    assert_equal( false, @fs.fsck_enabled ) 
  end
  
  public
  def test_set_options
    assert_equal( [ "-c"], @fs.format_options )
    assert_equal( [ "-v" ], @fs.mount_options )
  end
  
  public
  def test_format_program
    assert_equal( "mkswap -c /dev/hda2", @fs.dump_format( "/dev/hda2" ) )
  end
  
  public
  def test_mount_program
    assert_equal( "swapon -v /dev/hda2 ", @fs.dump_mount( "/dev/hda2", "" ) )
  end

end

### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
