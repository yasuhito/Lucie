#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

require 'lucie/config/resource'
require 'lucie/setup-harddisks/old-partition'

module Lucie
  module SetupHarddisks
    class Disk < Lucie::Config::Resource
      # 登録されている Disk のリスト
      @@list = {}
      
      # アトリビュート名のリスト: [:name, :version, ...]
      @@required_attributes = []
      
      # _すべての_ アトリビュート名とデフォルト値のリスト: [[:name, nil], [:version, '0.0.1'], ...]
      @@attributes = [[:bootable_device, false]]
      
      # アトリビュート名からデフォルト値へのマッピング
      @@default_value = {}
      
      # ------------------------- REQUIRED attributes.
      
      required_attribute :name            # device name
      required_attribute :disk_unit
      required_attribute :disk_size
      required_attribute :bootable_device
      required_attribute :boot_partition
      required_attribute :sector_alignment

      attr_reader :primary_partitions
      attr_reader :logical_partitions
      attr_reader :extended_partitions
      attr_reader :old_partitions
      attr_reader :number_of_primary_partitions
      attr_reader :number_of_logical_partitions
      
      # ------------------------- Public class methods.

      private
      def self.list_disks(res = nil)    # an arg is intended for test
        # e.g. ["sda", "sdb"]
        if res == nil
          result = `sfdisk -s`
        else
          result = res
        end
        return result.scan(/^\/dev\/(\w+)/).flatten
      end

      BLKID_PARTITION_ATTRIB_REGEXP = /\A\/dev\/([A-Za-z]+)(\d*):.*TYPE="(\w+)".*$/i
      
      public
      def self.save_old_partition_attrib(res = nil)    # an arg is indended for test
        if res == nil
          result = `blkid`
        else
          result = res
        end
        result.each do |line|
          if BLKID_PARTITION_ATTRIB_REGEXP =~ line
            disk=$1
            slice="#{disk}#{$2}"
            fs=$3
            @@list[disk].old_partitions[slice].fs = fs
          end
        end
      end

      public
      def self.assign_partition(part_list)
        # set_partition_positions などのため順序が重要
        part_list.each do |key, part|
          disk = part.disk
          raise StandardError, "Could not read device: /dev/#{disk}" unless @@list.has_key?(disk)
          if part.has_slice_number?
            case part.kind
            when "primary"
              if part.slice_number > MAX_PRIMARIES
                raise StandardError, "Partition after number #{MAX_PRIMARIES} must be a logical partition."
              end
              @@list[disk].primary_partitions[part.slice_number - 1] = part
            when "logical"
              if part.slice_number < FIRST_LOGICAL
                raise StandardError, "Partition before number #{FIRST_LOGICAL} must be a primary partition."
              end
              @@list[disk].logical_partitions[part.slice_number - 1] = part
            when "extended"
            # XXX: 設定ファイルで extended を明示指定するのは未サポート
              $stderr.puts "Extended partition is defined in config for #{part.slice}"
              @@list[disk].extended_partitions[part.slice_number - 1] = part
            when nil
              # may be preserve partition
              if part.slice_number < FIRST_LOGICAL
                @@list[disk].primary_partitions[part.slice_number - 1] = part
              else
                @@list[disk].logical_partitions[part.slice_number - 1] = part
              end
            else
              # should not reach here
              raise StandardError, "Invalid partition type: #{part.kind} for #{part.slice}"
            end
          end
        end
      
        part_list.each do |key, part|
          disk = part.disk
          unless part.has_slice_number?
            case part.kind
            when "primary"
              idx = @@list[disk].find_first_nil_idx(@@list[disk].primary_partitions)
              part.slice = "#{part.slice}#{idx + 1}"
              @@list[disk].primary_partitions[idx] = part
            when "logical"
              idx = @@list[disk].find_first_nil_idx(@@list[disk].logical_partitions[MAX_PRIMARIES, @@list[disk].logical_partitions.length]) + MAX_PRIMARIES
              part.slice = "#{part.slice}#{idx + 1}"
              @@list[disk].logical_partitions[idx] = part
            when "extended"
              idx = @@list[disk].find_first_nil_idx(@@list[disk].extended_partitions)
              part.slice = "#{part.slice}#{idx + 1}"
              @@list[disk].extended_partitions[idx] = part
            when nil
              # preserve partition
              if part.preserve
                # should not reach here
                raise StandardError, "The slice must be specified with slice number for preserve partition. (#{part.name})"
              else
                raise StandardError, "Unknown condition."
              end
            else
              # should not reach here
              raise StandardError, "Invalid partition type: #{part.kind} for #{part.slice}"
            end
          end

          if part.bootable
            if @@list[disk].bootable_device && @@list[disk].boot_partition != part
              raise StandardError, "Only one partition can be bootable at a time."
            else
              @@list[disk].bootable_device = true
              @@list[disk].boot_partition = part
            end
          end
        end
      end

      private
      def self.slice_to_logical_idx(sl_num)
        return sl_num - FIRST_LOGICAL
      end

      public
      def find_first_nil_idx(array)
        idx = 0
        unless array.empty?
          array.each do |each|
            break if each.nil?
            idx += 1
          end
        end
        return idx
      end

      public
      def self.check_settings
        # XXX: 関数の呼び出し順に依存あり
        check_preserve_partition
        check_swap_partition
        check_number_of_bootable_devices
        check_number_of_primary_partitions
        calc_requested_partition_size
      end

      public
      def self.write_fstab
        fstab = <<-EOF
# /etc/fstab: static file system information.
#
#<file sys>  <mount point>     <type>   <options>   <dump>   <pass>
        EOF
        @@list.each do |key, disk|
          fstab += disk.write_fstab
        end
        
        if $commandline_options.no_test
          out_file = "#{$commandline_options.log_dir}/fstab"
          begin
            puts fstab if $commandline_options.verbose
            File.open(out_file, "w") do |file| file.puts fstab end
          rescue => ex
            raise
          end
        else
          puts fstab unless Test::Unit.run?
        end
      end
      
      public
      def self.write_lucie_variables
        out_file = "#{$commandline_options.log_dir}/#{RESULT_FILE}"
        puts "Write Lucie variables to file #{out_file}" if $commandline_options.verbose
        swaps = []
        boot_dev = root_part = boot_part = nil
        @@list.each do |key, disk|
          disk.partitions.each do |part|
            swaps << "/dev/#{part.slice}" if part.fs.instance_of?(Swap)
            root_part = part.slice if part.mount_point == "/"
          end
          if disk.bootable_device
            boot_dev = disk.name 
            boot_part = disk.boot_partition.slice
          end
        end

        result = <<-EOF
BOOT_DEVICE=/dev/#{boot_dev}
ROOT_PARTITION=/dev/#{root_part}
BOOT_PARTITION=/dev/#{boot_part}
SWAPLIST=#{swaps.join(' ')}
        EOF
        
        if $commandline_options.no_test
          begin
            puts result if $commandline_options.verbose
            File.open(out_file, "w") do |file| file.puts result end
          rescue => ex
            raise
          end
        else
          puts result unless Test::Unit.run?
        end
      end

      # ------------------------- Special accessor behaviours (overwriting default).

      overwrite_accessor :name= do |_name|
        unless (_name.nil?) || ( /\A[\w\-_\/]+\z/ =~ _name)
          raise InvalidAttributeException, "Invalid attribute for name: #{_name}"
        end
        @name = _name.gsub(/^\/dev\//, '').downcase unless _name.nil?
      end


      # ------------------------- Constructor

      public
      def initialize( dev, &block )
        set_default_values
        ENV['LC_ALL']='C'
        @name = dev
        @primary_partitions = Array.new(MAX_PRIMARIES)
        @logical_partitions = Array.new(FIRST_LOGICAL)
        @extended_partitions = []
        @old_partitions = {}
        yield self if block_given?
        register
      end
      
      # ------------------------- Public instance methods

      SFDISK_CHS_REGEXP = /\A\/dev\/(.+?):\s+(\d+)\s+cylinders,\s+(\d+)\s+heads,\s+(\d+)\s+sectors/i
      
      public
      def probe_disk_unit(res = nil)    # an arg is intended for test
        if res == nil
          result = `sfdisk -g -q "/dev/#{@name}"`
        else
          result = res
        end
        if SFDISK_CHS_REGEXP =~ result
          @disk_unit = $3.to_i * $4.to_i;  # heads * sectors = cylinder size in sectors
          @disk_size = $2.to_i;            # cylinders
          ($commandline_options.dos_alignment == true) ? (@sector_alignment = $4.to_i) : (@sector_alignment = 1)            
        end
      end
      
      SFDISK_PARTITION_TABLE_REGEXP = /\A\/dev\/(.+?)\s*:\s+start=\s*(\d+),\s+size=\s*(\d+),\s+Id=\s*([a-z0-9]+)\b(.*)$/i
      
      public
      def save_old_partition(res = nil)    # an arg is intended for test
        if res == nil
          result = `sfdisk -d -q "/dev/#{@name}"`
        else
          result = res
        end
        result.each do |line|
          if SFDISK_PARTITION_TABLE_REGEXP =~ line
            slice = $1
            unless @old_partitions.has_key?(slice)
              @old_partitions[slice] = OldPartition.new
            end
            @old_partitions[slice].start_sector = $2.to_i
            @old_partitions[slice].end_sector = $2.to_i + $3.to_i - 1
            @old_partitions[slice].start_unit = @old_partitions[slice].start_sector / @disk_unit
            @old_partitions[slice].end_unit = @old_partitions[slice].end_sector / @disk_unit
            
            tmp = $2.to_i / @sector_alignment.to_f
            @old_partitions[slice].not_aligned = true if tmp != tmp.to_i
            tmp = $3.to_i / @sector_alignment.to_f
            @old_partitions[slice].not_aligned = true if tmp != tmp.to_i
            
            @old_partitions[slice].id = $4.to_i(16)
            
            rest = $5
            @old_partitions[slice].bootable = (/bootable/ =~ rest) ? true : false;
          end
        end
      end
      
      public
      def partitions(compact = true)
        if compact
          parts = (@primary_partitions + @extended_partitions + @logical_partitions).compact
        else
          # XXX: @logical_partitions のサイズが最も大きいことに依存しすぎ
          parts = []
          @logical_partitions.each_index do |idx|
            if !@primary_partitions[idx].nil?
              parts[idx] = @primary_partitions[idx]
            elsif !@extended_partitions[idx].nil?
              parts[idx] = @extended_partitions[idx]
            elsif !@logical_partitions[idx].nil?
              parts[idx] = @logical_partitions[idx]
            else
              parts[idx] = nil
            end
          end
        end
        return parts
      end
      
      public
      def check_preserve_partition
        partitions.each do |part|
          if part.preserve
            slice = part.slice
            if @old_partitions.has_key?(slice)
              old_part = @old_partitions[slice]
            else
              raise StandardError, "Cannot preserve partition /dev/#{slice}. Partition not found."
            end
            
            if old_part.not_aligned
              raise StandardError, "Unable to preserve partition /dev/#{slice}. Partition is not DOS aligned."
            end
            
            if old_part.id == PARTITION_ID_EXTENDED ||
                 old_part.id == PARTITION_ID_LINUX_EXTENDED
              raise StandardError, "Extended partitions can not be preserved. /dev/#{slice}"
            end
            
            part.copy_from_old(old_part)
            
            unless @last_preserve_partition.nil?
              if old_part.start_unit < @old_partitions[@last_preserve_partition].start_unit
                raise StandardError, "Misordered partitions: cannot preserve partitions /dev/#{@last_preserve_partition} and /dev/#{slice} in this order because of their positions on disk."
              end
            end
            @last_preserve_partition = slice

            if part.size < 1
              raise StandardError, "Unable to preserve partitions of size 0."
            end
          else
            # If not preserve we must know the filesystem type. Default is ext2.
            part.fs = "ext2" if part.fs.nil?
          end
        end
      end

      public
      def check_swap_partition
        partitions.each do |part|
          if part.fs.instance_of?(Swap) && part.mount_point != "none"
            part.mount_point = "none"
            $stderr.puts "Mountpoints of swap partition should be 'none'"
          end
        end
      end

      public
      def check_number_of_primary_partitions
        if (@primary_partitions.nitems > (MAX_PRIMARIES - 1) && @logical_partitions.nitems > 0) ||
            @primary_partitions.nitems > MAX_PRIMARIES
          raise StandardError, "Too much primary partitions (max 4) for /dev/#{@name}. All logicals together need one primary too."
        end
      end

      public
      def calc_requested_partition_size
        partitions.each do |part|
          if part.size.is_a?(Range)
            part.min_size = ((part.size.first * MEGABYTE - 1) / (@disk_unit * SECTOR_SIZE)) + 1
            part.max_size = ((part.size.last  * MEGABYTE - 1) / (@disk_unit * SECTOR_SIZE)) + 1
            part.max_size = @disk_size if part.max_size > @disk_size
          else
            part.min_size = part.max_size = ((part.size * MEGABYTE - 1) / (@disk_unit * SECTOR_SIZE)) + 1
          end
        end
      end

      public
      def build_partition_table
        set_partition_positions
        # change units to sectors
        partitions.each do |each|
          unless each.preserve   # preserve partition は check_settings->check_preserve_partition でコピー済み
            each.start_sector = each.start_unit * @disk_unit
            each.end_sector = each.end_unit * @disk_unit - 1
            each.size *= @disk_unit
          end
          # align first partition for mbr
          if each.start_sector == 0
            each.start_sector += @sector_alignment
            each.size -= @sector_alignment
          end
        end
        
        # align all logical partitions
        @logical_partitions.each do |each|
          next if each.nil?
          if each.slice_number == FIRST_LOGICAL
            # First logical partition and start of extended partition
            @start_sector_of_extended = each.start_sector
            @start_sector_of_extended -= @sector_alignment if each.preserve
          end
          unless each.preserve
            each.start_sector += @sector_alignment
            each.size -= @sector_alignment
          end
        end
        
        calculate_extended_partition_size
        print_partition_table if $commandline_options.verbose
      end
      
      # set position for every partition
      private
      def set_partition_positions
        unpreserved_group = []
        start_position = end_position = 0
        partitions.each do |each|
          if each.preserve
            end_position = @old_partitions[each.slice].start_unit - 1
            set_unreserved_group_position(unpreserved_group, start_position, end_position)
            unpreserved_group.clear
            start_position = @old_partitions[each.slice].end_unit + 1
          else
            unpreserved_group << each
          end
        end
        end_position = @disk_size - 1
        set_unreserved_group_position(unpreserved_group, start_position, end_position)
        partitions.each do |each|
          if each.fs.instance_of?(Fat16) && each.size * @disk_unit * SECTOR_SIZE < 32 * MEGABYTE
            each.id = PARTITION_ID_FAT16S
          end
        end
      end
      
      # set position for a group of unpreserved partitions between start and end
      private
      def set_unreserved_group_position(unpreserved_group, start_position, end_position)
        return if unpreserved_group.empty?
        total_size = end_position - start_position + 1
        return if total_size <= 0
        
        min_total = max_min_total = rest = 0
        unpreserved_group.each do |each|
          min_total += each.min_size
          max_min_total += each.max_size - each.min_size
          each.size = each.min_size
        end
        
        # Test if partitions fit
        raise StandardError, "Mountpoints #{unpreserved_group} do not fit." if min_total > total_size
        # Maximize partitions
        rest = total_size - min_total
        rest = max_min_total if rest > max_min_total
        if rest > 0
          unpreserved_group.each do |each|
            each.size += ((each.max_size - each.min_size) * rest) / max_min_total
          end
        end
        # compute rest
        rest = total_size
        unpreserved_group.each do |each|
          rest -= each.size
        end
        # Minimize rest
        unpreserved_group.each do |each|
          if (rest > 0) && (each.size < each.max_size)
            each.size += 1
            rest -= 1
          end
        end
        # Set start for every partition
        unpreserved_group.each do |each|
          each.start_unit = start_position
          each.end_unit = start_position += each.size
        end
      end

      public
      def fdisk
        if partitions.empty?
          message "Skipping sfdisk on /dev/#{@name}: there is no partitions" if $commandline_options.verbose
          return
        end
        sfdisk_table = "# partition table of device: /dev/#{@name}\n\n"

        partitions(false).each_with_index do |part, idx|
          if part.nil?
            if idx < MAX_PRIMARIES
              sfdisk_table += build_sfdisk_dump_line(build_slice_name(idx+1), 0, 0, 0) + "\n"
            end
          else
            line = build_sfdisk_dump_line(part.slice, part.start_sector, part.size, part.id.to_s(16))
            line += ", bootable" if part == boot_partition
            sfdisk_table += "#{line}\n"
          end
        end

        sfdisk_input_file = $commandline_options.log_dir + "/#{SFDISK_PARTITION_FILE_PREFIX}." + @name.gsub('/', '_')
        if $commandline_options.no_test
          begin
            File.open(sfdisk_input_file, "w") do |file|
              file.printf sfdisk_table
            end
          rescue => ex
            raise
          end
          printf sfdisk_table if $commandline_options.verbose
        else
          message sfdisk_table 
        end
        command = "sfdisk -q -uS /dev/#{@name} < #{sfdisk_input_file}"
        if $commandline_options.no_test
          `#{command}`
        else
          message command
        end
      end
      
      public
      def format
        partitions.each do |each|
          each.format
        end
      end
      
      public
      def mount
        # not used
        partitions.each do |each|
          each.mount
        end
      end
      
      public
      def write_fstab
        fstab = ""
        partitions.each do |part|
          fstab += part.write_fstab
        end
        return fstab
      end

      # ------------------------- Private class methods

      private
      def self.check_preserve_partition
        @@list.each do |key, disk|
          disk.check_preserve_partition
        end
      end
      
      private
      def self.check_swap_partition
        @@list.each do |key, disk|
          disk.check_swap_partition
        end
      end
      
      private
      def self.check_number_of_bootable_devices
        number_of_bootable_device = 0
        boot_part = nil
        @@list.each do |key, disk|
          if disk.bootable_device
            number_of_bootable_device += 1
            boot_part = disk.boot_partition
          end
        end
        if number_of_bootable_device == 0
          @@list.each do |key, disk|
            disk.partitions.each do |part|
            # XXX: /boot パーティションを優先すべきなのか？
              if part.mount_point == "/"
                disk.bootable_device = true
                disk.boot_partition = boot_part = part
                number_of_bootable_device += 1
              end
            end
          end
        end
        if number_of_bootable_device == 0
          $stderr.puts "WARNING: There is no bootable device."
        elsif number_of_bootable_device == 1 && boot_part.mount_point == "none"
          $stderr.puts "WARNING: The boot partition has no mount point."
        elsif number_of_bootable_device > 1
          raise StandardError, "Only one device must be bootable."
        end
      end
            
      private
      def self.check_number_of_primary_partitions
        @@list.each do |key, disk|
          disk.check_number_of_primary_partitions
        end
      end

      private
      def self.calc_requested_partition_size
        @@list.each do |key, disk|
          disk.calc_requested_partition_size
        end
      end
      
      # ------------------------- Private instance methods
      
      # calculate extended partition size
      private
      def calculate_extended_partition_size
        ext_part = insert_extended_partition
        return if ext_part.nil?
        ext_end = @start_sector_of_extended
        @logical_partitions.each do |part|
          next if part.nil?
          new_end = 
          ext_end = part.end_sector if part.end_sector > ext_end
        end
        ext_part.start_sector = @start_sector_of_extended
        ext_part.end_sector = ext_end
        ext_part.size = ext_part.end_sector - ext_part.start_sector + 1
      end

      private
      def insert_extended_partition
        return if partitions.empty?
        return if @logical_partitions.nitems == 0
        if @primary_partitions.nitems >= MAX_PRIMARIES
           # should not reach here
          raise StandardError, "There is no space for extended partition"
        end
=begin
        # primary の間に extended を入れる
        # この場合 extended_partitions は使用されない
        slice_num = find_first_nil_idx(@primary_partitions) + 1
        ext_part = partition "#{@name}#{slice_num}_extended" do |part|
          part.slice = "#{@name}#{slice_num}"
          part.kind = "extended"
          part.size = 0
          part.id = PARTITION_ID_EXTENDED
        end
        @primary_partitions[slice_num - 1] = ext_part
        return ext_part
=end
        # primary の間に extended を入れない
        slice_num = find_last_nil_idx(@primary_partitions[0, MAX_PRIMARIES]) + 1
        ext_part = partition "#{@name}#{slice_num}_extended" do |part|
          part.slice = "#{@name}#{slice_num}"
          part.kind = "extended"
          part.size = 0
          part.id = PARTITION_ID_EXTENDED
        end
        @extended_partitions[slice_num - 1] = ext_part
        return ext_part

      end
      
      public
      def find_last_nil_idx(array)
        idx = array.length - 1
        array.reverse_each do |each|
          break unless each.nil?
          idx -= 1
        end
        return idx + 1
      end

      private
      def print_partition_table
        partitions.each do |each|
          if each.mount_point.nil?#
            mp = "none"
          else
            mp = each.mount_point
          end
          message "/dev/#{each.slice} #{mp} start=#{each.start_sector} size=#{each.size} end=#{each.end_sector} id=0x#{each.id.to_s(16)}"
        end
      end
      
      private
      def build_slice_name(num)
        return "#{@name}#{num}"
      end

      private
      def message( aString )
        puts aString unless Test::Unit.run?
      end
      
      private
      def build_sfdisk_dump_line(*param)
        sprintf "/dev/%-5s: start=%10s, size=%10s, Id=%3s", *param
      end
    end
  end
end

### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
