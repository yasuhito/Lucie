#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $LastChangedRevision$
# License::  GPL2

require 'English'
require 'lucie/setup-harddisks/command-line-options'
require 'lucie/setup-harddisks/disk'
require 'lucie/setup-harddisks/partition'
require 'singleton'

include Lucie::SetupHarddisks

module Lucie
  module SetupHarddisks
    class SetupHarddisks
      include Singleton

      LUCIE_VERSION = '0.0.1alpha'.freeze
      VERSION_STRING = [ 'setup-harddisk', LUCIE_VERSION ].join(' ')
      
      public
      def main
        begin
          do_option
        rescue GetoptLong::InvalidOption => io
          $stderr.puts( io.message )
          help
          exit(0)
        rescue SystemExit => ex
          $stderr.puts( ex.message ) unless( ex.success? )
          exit(0)
        end
        
        print_verbose_message("Lucie: " + VERSION_STRING + "\n")
        
        partition_data = load_configuration
        
        print_verbose_message("Probing disks... ")
        
        disks = Disk.list_disks
        
        print_verbose_message("done. Disks found: " + disks.join(' ') + "\n")
        
        disk_info = []
        disks.each do |each| disk_info << Disk.new(each) end
        disk_info.each do |each|
          each.probe_disk_unit
          each.save_old_partition
        end
        Disk.save_old_partition_attrib
        Disk.assign_partition(partition_data)
        Disk.check_settings
        disk_info.each do |disk|
           disk.build_partition_table
           disk.fdisk
           disk.format
         end
        Disk.write_fstab
        Disk.write_lucie_variables
      end

      private
      def do_option
        $commandline_options = CommandLineOptions.instance
        $commandline_options.parse ARGV.dup      
        if $commandline_options.help
          help
          exit
        end
      end
  
      private
      def usage
        puts "Usage: setup-harddisk {options}"
      end
      
      private
      def help
        puts VERSION_STRING
        puts
        usage
        puts
        puts "Options:"
        CommandLineOptions::OptionList::OPTION_LIST.each do |long, short, arg, desc|
          opt = sprintf("%25s", "#{long}, #{short}")
          oparg = sprintf("%-7s", arg)
          print "#{opt} #{oparg}"
          desc = desc.split("\n")
          if arg.nil? || arg.length < 7
            puts desc.shift
          else
            puts
          end
          desc.each do |line|
            puts(' '*33 + line)
          end
          puts
        end
      end
      
      private
      def load_configuration
        print_verbose_message("Parsing #{$commandline_options.config_file}... ")
        require $commandline_options.config_file
        print_verbose_message("done.\n")
        return Partition.list
      end
      
      private
      def print_verbose_message(msg)
        print msg if $commandline_options.verbose
      end
    end
  end
end

########
# Main #
########

if __FILE__ == $PROGRAM_NAME
  Lucie::Setup.instance.main
end

### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
