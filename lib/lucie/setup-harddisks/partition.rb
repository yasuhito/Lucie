#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

require 'lucie/config/resource'
require 'lucie/setup-harddisks/const'
require 'lucie/setup-harddisks/ext2'
require 'lucie/setup-harddisks/ext3'
require 'lucie/setup-harddisks/reiserfs'
require 'lucie/setup-harddisks/xfs'
require 'lucie/setup-harddisks/swap'
require 'lucie/setup-harddisks/fat16'
require 'lucie/setup-harddisks/fat32'

include Lucie::SetupHarddisks

module Lucie
  module SetupHarddisks
    class Partition < Lucie::Config::Resource
      # 登録されている Partition のリスト
      @@list = {}
      
      # アトリビュート名のリスト: [:name, :version, ...]
      @@required_attributes = []
      
      # _すべての_ アトリビュート名とデフォルト値のリスト: [[:name, nil], [:version, '0.0.1'], ...]
      @@attributes = [[:bootable, false], [:not_aligned, false],
                      [:preserve, false], [:dump_enabled, false]]

      # アトリビュート名からデフォルト値へのマッピング
      @@default_value = {}
      
      # Same as :attribute, but ensures that values assigned to the
      # attribute are array values by applying :to_a to the value.
      def self.array_attribute(name)
        @@attributes << [name, []]
        module_eval %{
          def #{name}
  	      @#{name} ||= []
  	    end
          def #{name}=(value)
  	      @#{name} = value.to_a
  	    end
        }
      end
      
      # label, slice, mount_point はシステム中重なってはいけない(UnionFSなどは非サポート）
      @@defined_labels = {}
      @@defined_slices = {}
      @@defined_mount_points = {}
      
      # 必須属性（nil 以外の値が必要）
      @@essential_attributes_for_preserve = [:slice]
      @@essential_attributes_for_non_preserve = [:slice, :type, :size]

      # 登録されているリソースをクリアする
      public
      def self.clear
        super
        @@defined_labels.clear
        @@defined_slices.clear
        @@defined_mount_points.clear
      end
            
      # ------------------------- REQUIRED attributes.
      
      # XXX: 以下は OldPartition と共通。スーパークラスとしてくくりだすべきだが、
      # @@list などのクラス変数も共有されてしまうため、整理が必要。
      # overwrite_accessor で使用している remove_method はスーパークラスのメソッ
      # ドは削除できないこと、Module としてくくりだして include した場合も実態は
      # 無名のスーパークラスに入れられるためやはり remove_method が使えないこと
      # などに注意。
      required_attribute :name          # partition name. e.g. usr, home, ...
      required_attribute :slice         # slice name, e.g. hda1, sdb2
      required_attribute :type          # primary | logical
      required_attribute :fs            # swap|ext2|ext3|reiserfs|xfs|fat16|fat32
      required_attribute :size          # 100, (10...90)
      required_attribute :max_size
      required_attribute :min_size
      required_attribute :bootable      # true | false
      required_attribute :mount_point   # /, /usr, ..., none
      array_attribute    :mount_option  # rw, nosuid, ...

      required_attribute :start_sector
      required_attribute :end_sector
      required_attribute :start_unit
      required_attribute :end_unit
      required_attribute :not_aligned
      required_attribute :id            # Partition ID is determined based on fs
      #ここまで OldPartition と共通

      required_attribute :preserve      # Preserve the existing partition
      required_attribute :dump_enabled  # dump options for fstab
      array_attribute    :format_option # -c, -f, ...
      array_attribute    :fstab_option  # options for fstab
            
      # ------------------------- Constructor.
      
      public
      def initialize( label, &block ) # :yield: self
        set_default_values
        self.name = label
        @essential_attributes = @@essential_attributes_for_non_preserve
        yield self if block_given?
        register
        check_essential_attributes
      end
  
      # ------------------------- Special accessor behaviours (overwriting default).
      overwrite_accessor :name= do |_name|
        unless (_name.nil?) || ( /\A[\w\-_]+\z/ =~ _name)
          raise InvalidAttributeException, "Invalid attribute for name: #{_name}"
        end
        if !_name.nil?
          if @@defined_labels.has_key?(_name)
            raise InvalidAttributeException, "Disk #{_name} is redefined."
          else
            @@defined_labels[_name] = self
          end
        end
        @name = _name
      end

      overwrite_accessor :slice= do |_slice|
        unless (_slice.nil?) || ( /\A[\w\-_\/]+\z/ =~ _slice)
          raise InvalidAttributeException, "Invalid attribute for slice: #{_slice}"
        end
        unless _slice.nil?
          sl = _slice.gsub(/^\/dev\//, '').downcase
          if has_slice_number?(sl)
            if slice_number(sl) > 0
              if @@defined_slices.has_key?(sl)
                raise InvalidAttributeException, "Slice /dev/#{sl} is redefined."
              else
                @@defined_slices[sl] = self
              end
            else
              raise InvalidAttributeException, "Slice number must be larger than 1 (#{sl})"
            end
          elsif @preserve
            raise InvalidAttributeException, "Preserve partition must be specified with slice number: #{@name}:#{@slice}"
          end
        end
        @slice = sl
      end
      
      overwrite_accessor :type= do |_type|
        unless (_type.nil?) || /primary|logical|extended/i =~ _type
          raise InvalidAttributeException, "Invalid attribute for kind: #{_kind}"
        end
        if _kind == "logical" && @bootable
          raise InvalidAttributeException, "Only primary partitions can be bootable."
        end
        @kind = _kind
      end
      
      overwrite_accessor :fs= do |_fs|
        case _fs
        when /swap/i
          @fs = Swap.new
          @id = PARTITION_ID_LINUX_SWAP
          if @bootable
            raise InvalidAttributeException, "Swap partition cannot be bootable."
          end
        when /ext2/i
          @fs = Ext2.new
          @id = PARTITION_ID_LINUX_NATIVE
        when /ext3/i
          @fs = Ext3.new
          @id = PARTITION_ID_LINUX_NATIVE
        when /reiserfs/i
          @fs = Reiserfs.new
          @id = PARTITION_ID_LINUX_NATIVE
        when /xfs/i
          @fs = Xfs.new
          @id = PARTITION_ID_LINUX_NATIVE
        when /fat16/i
          @fs = Fat16.new
          @id = PARTITION_ID_FAT16
        when /fat32/i
          @fs = Fat32.new
          @id = PARTITION_ID_FAT32
        when nil
          @fs = nil
        else
          raise InvalidAttributeException, "Unknown file system: " + _fs
        end
      end
      
      overwrite_accessor :size= do |_size|
        unless _size.nil? || _size.is_a?(Numeric) || _size.is_a?(Range)
          raise InvalidAttributeException, "Invalid attribute for size: #{_size}"
        end
        @size = _size
      end
      
      overwrite_accessor :preserve= do |_preserve|
        unless _preserve.nil? || _preserve.instance_of?(FalseClass) || _preserve.instance_of?(TrueClass)
          raise InvalidAttributeException, "Invalid attribute for preserve: #{_preserve}"
        end
        if _preserve
          @essential_attributes = @@essential_attributes_for_preserve
          unless @slice.nil?
            unless has_slice_number?
              raise InvalidAttributeException, "Preserve partition must be specified with slice number: #{@name}:#{@slice}"
            end
          end
        else
          @essential_attributes = @@essential_attributes_for_non_preserve
        end
        @preserve = _preserve
      end
      
      overwrite_accessor :bootable= do |_bootable|
        unless _bootable.nil? || _bootable.instance_of?(FalseClass) || _bootable.instance_of?(TrueClass)
          raise InvalidAttributeException, "Invalid attribute for bootable: #{_bootable}"
        end
        if _bootable && @kind == "logical"
          raise InvalidAttributeException, "Only primary partitions can be bootable."
        end
        if _bootable && @fs.instance_of?(Swap)
          raise InvalidAttributeException, "Swap partition cannot be bootable."
        end
        @bootable = _bootable
      end
      
      overwrite_accessor :mount_point= do |_mp|
        unless _mp.nil? || (/\A\/.*\z|\Aswap\z|\A-\z|\Anone\z/i =~ _mp)
          raise InvalidAttributeException, "Invalid attribute for mount_point: #{_mp}"
        end
        if !_mp.nil?
          if @@defined_mount_points.has_key?(_mp)
            raise InvalidAttributeException, "Mountpoint #{_mp} is redefined."
          elsif /\Aswap\z|\A-\z|\Anone\z/i =~ _mp
            _mp = "none"
          else
            @@defined_mount_points[_mp] = self
          end
        else
          _mp = "none"
        end
        @mount_point = _mp
      end
      
      overwrite_accessor :dump_enabled= do |_dump_enabled|
        unless _dump_enabled.nil? || _dump_enabled.instance_of?(FalseClass) || _dump_enabled.instance_of?(TrueClass)
          raise InvalidAttributeException, "Invalid attribute for dump_enabled: #{_dump_enabled}"
        end
        @dump_enabled = _dump_enabled
      end

      # -------------------------
      
      public
      def copy_from_old(old_part)
        @start_unit   = old_part.start_unit
        @start_sector = old_part.start_sector
        @end_unit     = old_part.end_unit
        @end_sector   = old_part.end_sector
        @not_aligned  = old_part.not_aligned
        @id           = old_part.id
        self.fs       = old_part.fs
        @size = @min_size = @max_size = old_part.end_sector - old_part.start_sector + 1
      end
      
      public
      def disk
        return @slice.gsub(/\d*\z/, '')
      end
      
      public
      def slice_number(sl = nil)
        sl = @slice if sl.nil?
        sl_num = sl[/\d+\z/]
        return sl_num.to_i unless sl_num.nil?
      end
      
      public
      def has_slice_number?(sl = nil)
        return slice_number(sl) != nil
      end
      
      public
      def format
        if @preserve
          if $commandline_options.verbose
            print "Preserve partition /dev/#{@slice}"
            if @mount_point.nil? || /\Aswap\z|\A-\z|\Anone\z/i =~ @mount_point
              puts " with no mountpoint"
            else
              puts " with mountpoint #{@mount_point}"
            end
          end
        elsif @kind != "extended"
          @fs.format("/dev/#{slice}", @name, @format_option)
        end
      end
      
      public
      def mount
        # not used
        if @kind != "extended"
          @fs.mount("/dev/#{slice}", @mount_point, @mount_option)
        end
      end
      
      public
      def mount_with_label
        # not used
        if @kind != "extended"
          @fs.mount_with_label(@name, @mount_point, @mount_option)
        end
      end
      
      public
      def write_fstab
        return "" if @kind == "extended"
        (@dump_enabled)? dump = 1 : dump = 0
        if @fs.fsck_enabled
          (@bootable)? fsck_order = 1 : fsck_order = 2
        else
          fsck_order = 0
        end
        fstab_options = (@fs.fstab_options + @fstab_option).uniq.join(',')
        fstab = build_fstab_line("/dev/#{@slice}", @mount_point, @fs.fs_type, fstab_options, dump, fsck_order)
        if @bootable
          # XXX: Proc < Filesystem できちんと対応したい
          fstab += build_fstab_line("proc", "/proc", "proc", "defaults", 0, 0)
        end
        return fstab
      end

      private
      def build_fstab_line(*param)
        sprintf "%-10s   %-15s   %-6s   %-8s  %-4s %-4s\n", *param;
      end
      
      private
      def check_essential_attributes
        @essential_attributes.each do |each|
          if (self.send "#{each}").nil?
            raise InvalidAttributeException, "Essential attributes #{each} is not set for #{@name}"
          end
        end
      end

      # ------------------------- Debug methods.

      public
      def inspect
        return to_s
      end
      
      public
      def to_s
        return "#<Lucie::SetupHarddisks::Partition name=#{@name} version=#{@version}>"
      end

    end

    class InvalidAttributeException < ::Exception; end
  end
end
### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
