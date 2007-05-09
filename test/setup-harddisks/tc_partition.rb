#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

$LOAD_PATH.unshift './lib'

require 'lucie/setup-harddisks/command-line-options'
require 'lucie/setup-harddisks/config'
require 'test/unit'

include Lucie::SetupHarddisks

class TC_Partition < Test::Unit::TestCase
  public
  def setup
    $commandline_options = CommandLineOptions.instance
    @part1 = partition "root"  do |part|
      part.slice = "/dev/sda1"
      part.kind = "primary"
      part.fs = "ext3"
      part.mount_point = "/"
      part.size = (128...200)
      part.bootable = true
      part.mount_option << "rw" << "nosuid"
      part.format_option << "-c"
    end
    
    @part2 = partition "swap" do |part|
      part.slice = "/dev/sda2"
      part.kind = "logical"
      part.fs = "swap"
      part.mount_point = "swap"
      part.size = 1024
    end
  end
  
  public
  def teardown
    Partition.clear
  end
  

  # 各属性に値をセットできることをテスト
  public
  def test_setter_methods
    [:name, :kind, :fs, :format_option].each do |each|
      setter_method_test each
    end
  end

  private
  def setter_method_test( attributeNameSymbol )
    begin
      partition attributeNameSymbol.to_s do |part|
        part.slice = attributeNameSymbol.to_s + "1"
        part.preserve = true
        part.send( attributeNameSymbol.to_s + '=', nil )
      end
    rescue
      fail "#{attributeNameSymbol} 属性に値をセットするときにエラーが発生"
    end
  end
  
  public
  def test_set_values
    assert_equal( "root", @part1.name )
    assert_equal( "sda1", @part1.slice )
    assert_equal( "primary", @part1.kind )
    assert_instance_of(Ext3, @part1.fs)
    assert_equal( "/", @part1.mount_point )
    assert_equal( (128...200), @part1.size )
    assert_equal( true, @part1.bootable )
    assert_equal( [ "rw", "nosuid" ], @part1.mount_option )
    assert_equal( [ "-c" ], @part1.format_option )
  end
  
  public
  def test_set_values_with_condition
    disk_size = 120
    @part1.size =
      if disk_size < 100
        20
      elsif disk_size < 200
        80
      else
        120
      end
    assert_equal( 80, @part1.size )
  end
  
  # 各アクセッサのテスト

  public
  def test_set_name
    assert_raises(InvalidAttributeException) {
      @part2.name = "*"
    }
    assert_nothing_raised {
      @part2.name = "home2"
    }
  end
  
  public
  def test_set_slice
    assert_raises(InvalidAttributeException) {
      @part2.slice = "hda0"         # slice number は1以上
    }
  end
  
  public
  def test_set_kind
    assert_nothing_raised {
      @part2.kind = "prImary"
      @part2.kind = "logical"
      @part2.kind = "extended"
      @part2.kind = nil
    }
    assert_raises(InvalidAttributeException) {
      @part2.kind = "invalid"
    }
  end
  
  public
  def test_set_fs
    assert_raises(InvalidAttributeException) {
      @part2.fs = "sapw"
    }
    assert_nothing_raised {
      @part2.fs = "ext2"
      @part2.fs = "ExT3"
      @part2.fs = "ReiserFS"
      @part2.fs = "XFS"
      @part2.fs = "swaP"
      @part2.fs = "fat16"
      @part2.fs = "Fat32"
    }
  end
  
  public
  def test_set_size
    assert_raises(InvalidAttributeException) {
      @part2.size = "string"
    }
    assert_nothing_raised {
      @part2.size = 10
      @part2.size = 10.10
      @part2.size = (10..100)
    }
  end
  
  public
  def test_set_mount_point
    assert_raises(InvalidAttributeException) {
      @part2.mount_point = "invalid"
    }
    assert_nothing_raised {
      @part2.mount_point = "/usr"
      @part2.mount_point = "/usr/local"
      @part2.mount_point = "SwAP"
      @part2.mount_point = "-"
    }
  end
  
  public
  def test_set_preserve
    assert_nothing_raised {
      @part1.preserve = true
      @part1.preserve = false
    }
    assert_raises(InvalidAttributeException) {
      @part1.preserve = "yes"
    }
    assert_raises(InvalidAttributeException) {
      partition "test1" do |part|
        part.slice = "sda"
        part.preserve = true
      end
    }
    assert_raises(InvalidAttributeException) {
      partition "test2" do |part|
        part.preserve = true
        part.slice = "sda"
      end
    }
  end
  
  public
  def test_set_dump_enabled
    assert_nothing_raised {
      @part1.dump_enabled = true
      @part1.dump_enabled = false
    }
    assert_raises(InvalidAttributeException) {
      @part1.dump_enabled = "yes"
    }
  end
  
  public
  def test_bootability1
    assert_nothing_raised {
      @part1.bootable = true
      @part1.kind = "primary"
    }
    assert_raises(InvalidAttributeException) {
      @part1.bootable = true
      @part1.kind = "logical"
    }
  end
  
  public
  def test_bootability2
    assert_nothing_raised {
      @part1.kind = "primary"
      @part1.bootable = true
    }
    assert_raises(InvalidAttributeException) {
      @part1.kind = "logical"
      @part1.bootable = true
    }
  end
  
  public
  def test_essential_attributes
    assert_nothing_raised {
      partition "test1" do |part|
        part.preserve = true
        part.slice = "hda1"
      end
      
      partition "test2" do |part|
        part.slice = "hda2"
        part.kind = "primary"
        part.size = 100
      end

      partition "test3" do |part|
        part.preserve = false
        part.slice = "hda3"
        part.kind = "primary"
        part.size = 100
      end
    }
    
    assert_raises(InvalidAttributeException) {
      partition "test4" do |part|
      end
    }
    
    assert_raises(InvalidAttributeException) {
      partition "test5" do |part|
        part.preserve = true
      end
    }
    
    assert_raises(InvalidAttributeException) {      
      partition "test6" do |part|
        part.preserve = false
        part.kind = "logical"
        part.size = 100
      end
    }

    assert_raises(InvalidAttributeException) {      
      partition "test7" do |part|
        part.preserve = false
        part.slice = "hda7"
        part.size = 100
      end
    }

    assert_raises(InvalidAttributeException) {      
      partition "test8" do |part|
        part.preserve = false
        part.slice = "hda8"
        part.kind = "logical"
      end
    }
  end
  
  public
  def test_redundant_definition
    partition "test" do |part|
      part.slice = "hda1"
      part.kind = "primary"
      part.size = 100
      part.mount_point = "/mnt/test"
    end
    
    assert_raises(InvalidAttributeException) {
      # label "test" is redefined
      partition "test" do |part|
        part.slice = "hda2"
        part.kind = "primary"
        part.size = 100
      end
    }

    assert_raises(InvalidAttributeException) {
      # slice is redefined
      partition "test2" do |part|
        part.slice = "hda1"
        part.kind = "primary"
        part.size = 100
      end
    }
      
    assert_raises(InvalidAttributeException) {
      # mount_point is redefined
      partition "test3" do |part|
        part.slice = "hda3"
        part.kind = "primary"
        part.size = 100
        part.mount_point = "/mnt/test"
      end
    }
  end
  
  # -------------------------
  
  public
  def test_format
    assert_nothing_raised {
      @part1.format
    }
  end
  
  public
  def test_write_fstab
    res = <<-EOF
/dev/sda1    /                 ext3     defaults  0    1   
proc         /proc             proc     defaults  0    0   
    EOF
    fstab = @part1.write_fstab
    assert_equal(res, fstab)
  end

  # ------------------------- Debug メソッドのテスト.

  public
  def test_to_s
    assert_equal( %{#<Lucie::SetupHarddisks::Partition name=root version=>}, @part1.to_s,
                  "Partition#to_s の返り値が正しくない" )
  end

  public
  def test_inspect
    assert_equal( %{#<Lucie::SetupHarddisks::Partition name=root version=>}, @part1.inspect,
                  "Partition#inspect の返り値が正しくない" )
  end
end

### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
