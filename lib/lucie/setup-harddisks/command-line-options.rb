require 'English'
require 'getoptlong'
require 'singleton'

module Lucie
  module SetupHarddisks

    # Lucie::CommandLineOptions Çì•èP
    class CommandLineOptions # :nodoc:
      include Singleton
      
      attr_reader :no_test
      attr_reader :config_file
      attr_reader :log_dir
      attr_reader :dos_alignment
      attr_reader :verbose
      attr_reader :help
            
      module OptionList # :nodoc:
        OPTION_LIST = [
          [ "--no-test",            "-X",  nil, \
            "no test, your harddisks will be formated. default: only test, no real formating." ],
          [ "--config-file",        "-f",  "config file", \
            "specify configuration file. default: parse classes." ],
          [ "--log-dir",            "-l", "log directory", \
            "specify a directory for log files. default: /tmp/lucie." ],
          [ "--dos-alignment",      "-d",  nil, \
            "default: no DOS alignment." ],
          [ "--verbose",             "-v",  nil, \
            "verbose mode, the program will print verbose messages." ],
          [ "--help",               "-h",  nil, \
            "you're looking at it." ],
        ]
          
        public
        def self.options
          return OPTION_LIST.map do |long, short, arg,|
            [long, 
             short, 
             arg ? GetoptLong::REQUIRED_ARGUMENT : GetoptLong::NO_ARGUMENT 
            ]
          end
        end
      end
        
      public
      def initialize
        set_default_options
      end
    
      # Parse the command line options.
      public
      def parse( argvArray )
        old_argv = ARGV.dup
        begin
          ARGV.replace argvArray
            
          getopt_long = GetoptLong.new( *OptionList.options )
          getopt_long.quiet = true
            
          getopt_long.each do |option, argument|
            case option
            when "--no-test"
              @no_test = true
            when "--config-file"
              @config_file = argument
            when "--log-dir"
              @log_dir = argument
            when "--dos-alignment"
              @dos_alignment = false
            when "--verbose"
              @verbose = true
            when "--help"
              @help = true
           end
          end
        ensure
          ARGV.replace old_argv
        end
      end
    
      private
      def set_default_options
        @no_test = false
        @config_file = "/etc/lucie/partition.rb"
        @log_dir = "/tmp/lucie"
        @dos_alignment = true
        @verbose = false
        @help = false
      end
    end

  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

