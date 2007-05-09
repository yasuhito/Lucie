#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

$LOAD_PATH.unshift './lib'

require 'lucie/setup-harddisks/command-line-options'
require 'lucie/setup-harddisks/ext2'
require 'test/unit'

include Lucie::SetupHarddisks

class TC_Ext2 < Test::Unit::TestCase
  public
  def setup
    $commandline_options = CommandLineOptions.instance
    @fs = Ext2.new
    @fs.format_options += [ "-n", "-q", "-v"]
    @fs.mount_options += [ "-v", "-r", "-w", "-o", "default,nosuid" ]
  end
  
  public
  def test_name
    assert_equal( "ext2", @fs.fs_type )
  end
  
  public
  def test_check_programs
    assert_equal( "mke2fs", @fs.format_program )
    assert_equal( "mount -t ext2", @fs.mount_program )
  end
  
  public
  def test_fsck_enabled
    assert_equal( true, @fs.fsck_enabled) 
  end
  
  public
  def test_set_options
    assert_equal( [ "-n", "-q", "-v"], @fs.format_options )
    assert_equal( [ "-v", "-r", "-w", "-o", "default,nosuid" ], @fs.mount_options )
  end
  
  public
  def test_format_program
    assert_equal( "mke2fs -n -q -v -L VOL /dev/hda1", @fs.dump_format( "/dev/hda1", "VOL" ) )
  end
  
  public
  def test_mount_program
    assert_equal( "mount -t ext2 -v -r -w -o default,nosuid /dev/hda1 /", @fs.dump_mount( "/dev/hda1", "/" ) )
  end

  public
  def test_mount_program_with_label
    assert_equal( "mount -t ext2 -v -r -w -o default,nosuid -L BOOT /", @fs.dump_mount_with_label( "BOOT", "/" ) )
  end

end

### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
