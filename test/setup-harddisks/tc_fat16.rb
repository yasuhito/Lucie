#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

$LOAD_PATH.unshift './lib'

require 'lucie/setup-harddisks/command-line-options'
require 'lucie/setup-harddisks/fat16'
require 'test/unit'

include Lucie::SetupHarddisks

class TC_Fat16 < Test::Unit::TestCase
  public
  def setup
    $commandline_options = CommandLineOptions.instance
    @fs = Fat16.new
    @fs.mount_options += [ "-v", "-r", "-w", "-o", "default,nosuid" ]
  end
  
  public
  def test_name
    assert_equal( "vfat", @fs.fs_type )
  end
  
  public
  def test_check_programs
    assert_equal( "mkfs.msdos", @fs.format_program )
    assert_equal( "mount -t vfat", @fs.mount_program )
  end
  
  public
  def test_fsck_enabled
    assert_equal( false, @fs.fsck_enabled) 
  end
  
  public
  def test_set_options
    assert_equal( [], @fs.format_options )
    assert_equal( [ "-v", "-r", "-w", "-o", "default,nosuid" ], @fs.mount_options )
  end
  
  public
  def test_format_program
    assert_equal( "mkfs.msdos -n VOL /dev/hda1", @fs.dump_format( "/dev/hda1", "VOL" ) )
  end
  
  public
  def test_mount_program
    assert_equal( "mount -t vfat -v -r -w -o default,nosuid /dev/hda1 /", @fs.dump_mount( "/dev/hda1", "/" ) )
  end

  public
  def test_mount_program_with_label
    assert_equal( "mount -t vfat -v -r -w -o default,nosuid -L BOOT /", @fs.dump_mount_with_label( "BOOT", "/" ) )
  end

end

### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
