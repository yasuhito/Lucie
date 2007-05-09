#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

$LOAD_PATH.unshift './lib'

require 'lucie/setup-harddisks/command-line-options'
require 'lucie/setup-harddisks/xfs'
require 'test/unit'

include Lucie::SetupHarddisks

class TC_Xfs < Test::Unit::TestCase
  public
  def setup
    $commandline_options = CommandLineOptions.instance
    @fs = Xfs.new
    @fs.mount_options += [ "-v", "-r", "-w", "-o", "default,nosuid" ]
  end
  
  public
  def test_name
    assert_equal( "xfs", @fs.fs_type )
  end
  
  public
  def test_check_programs
    assert_equal( "mkfs.xfs", @fs.format_program )
    assert_equal( "mount -t xfs", @fs.mount_program )
  end
  
  public
  def test_fsck_enabled
    assert_equal( false, @fs.fsck_enabled ) 
  end
  
  public
  def test_set_options
    assert_equal( [ "-f" ], @fs.format_options )
    assert_equal( [ "-v", "-r", "-w", "-o", "default,nosuid" ], @fs.mount_options )
  end
  
  public
  def test_format_program
    assert_equal( "mkfs.xfs -f -L VOL /dev/hda3", @fs.dump_format( "/dev/hda3", "VOL" ) )
  end
  
  public
  def test_mount_program
    assert_equal( "mount -t xfs -v -r -w -o default,nosuid /dev/hda3 /usr", @fs.dump_mount( "/dev/hda3", "/usr") )
  end

  public
  def test_mount_program_with_label
    assert_equal( "mount -t xfs -v -r -w -o default,nosuid -L USR /usr", @fs.dump_mount_with_label( "USR", "/usr") )
  end

end

### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
