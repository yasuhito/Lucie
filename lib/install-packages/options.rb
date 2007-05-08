#
# $Id: options.rb 1111 2007-03-02 08:12:44Z takamiya $
#
# Author::   Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision: 1111 $
# License::  GPL2


module InstallPackages
  class Options
    attr_reader :config_file
    attr_reader :dry_run


    PROGRAM_NAME = 'install_packages'.freeze
    VERSION = '0.0.1'.freeze
    VERSION_STRING = [ PROGRAM_NAME, VERSION ].join( ' ' )
    OPTIONS = { '--debug' => { :long_option => "--debug",
                               :short_option => "-D",
                               :argument => nil,
                               :description => "displays lots on internal stuff." ,
                               :default => nil,
                               :proc => Proc.new do | argument | $trace = true end },
                 '--help' => { :long_option => "--help",
                               :short_option => "-h",
                               :argument => nil,
                               :description => "you're looking at it.",
                               :default => nil,
                               :proc => Proc.new do | argument | OptionList.usage end },
              '--version' => { :long_option => "--version",
                               :short_option => "-v",
                               :argument => nil,
                               :description => "display #{ PROGRAM_NAME }'s version and exit.",
                               :default => nil,
                               :proc => Proc.new do | argument | STDOUT.puts VERSION_STRING end },
              '--dry-run' => { :long_option => "--dry-run",
                               :short_option => "-d",
                               :argument => nil,
                               :description => "no action.",
                               :default => nil,
                               :proc => Proc.new do | argument | @dry_run = true end },
          '--config-file' => { :long_option => '--config-file',
                               :short_option => '-c',
                               :argument => '[FILE]',
                               :description => 'specify a configuration file to use.',
                               :default => nil,
                               :proc => Proc.new do | argument | @config_file = argument end },
    }


    require 'getoptlong'


    OPTIONS.keys.each do | each |
      eval( 'attr_accessor :' + each.sub( /^--/, '' ).tr( '-', '_' ) )
    end


    module OptionList  #:nodoc:
      @@option_list = []


      def self.clear_options
        @@option_list = []
      end


      def self.register_options long, short, arg, desc
        @@option_list.push [ long, short, arg, desc ]
      end


      def self.options
        @@option_list.collect do | long, short, arg, |
          [ long, short, arg ? GetoptLong::REQUIRED_ARGUMENT : GetoptLong::NO_ARGUMENT ]
        end
      end


      def self.error messageString
        STDERR.puts
        STDERR.puts messageString
        STDERR.puts "For help on options, try '#{ PROGRAM_NAME } --help'"
      end


      def self.option_desc_tab
        @@option_list.collect do | long, short, arg, desc |
          if arg
            long.size + arg.size
          else
            long.size
          end
        end.sort.reverse[ 0 ] + 10
      end


      def self.usage
        STDOUT.puts
        STDOUT.puts VERSION_STRING
        STDOUT.puts
        STDOUT.puts "Options:"
        @@option_list.each do | long, short, arg, desc |
          STDOUT.print( if arg
                          sprintf "  %-#{ option_desc_tab }s", "#{ short }, #{ long }=#{ arg }"
                        else
                          sprintf "  %-#{ option_desc_tab }s", "#{ short }, #{ long } "
                        end )
          desc = desc.split( "\n" )
          STDOUT.puts desc.shift
          desc.each do | each |
            puts( ' ' * ( option_desc_tab + 2 ) + each )
          end
        end
        STDOUT.puts
      end
    end


    def initialize
      OptionList.clear_options
      register_options
      set_default_options
    end


    def parse argv
      set_default_options
      old_argv = ARGV.dup
      begin
        ARGV.replace argv
        getopt_long = GetoptLong.new( *OptionList.options )
        getopt_long.quiet = true
        getopt_long.each do | option, argument |
          if OPTIONS[ option ]
            self.__send__( eval( ':' + option.sub( /^--/, '' ).tr( '-', '_' ) + '=' ), ( argument != '' ? argument : true ) )
            OPTIONS[ option ][ :proc ].call( argument ) if OPTIONS[ option ][ :proc ]
          end
        end
      rescue GetoptLong::InvalidOption, GetoptLong::MissingArgument => error
        OptionList.error error.message
        raise error
      ensure
        ARGV.replace old_argv
      end
      return self
    end


    private


    def register_options
      OPTIONS.values.each do | each |
        OptionList.register_options each[ :long_option ], each[ :short_option ], each[ :argument ], each[ :description ]
      end
    end


    def set_default_options
      OPTIONS.keys.each do | each |
        self.__send__( eval( ':' + each.sub( /^--/, '' ).tr( '-', '_' ) + '=' ), OPTIONS[ each ][ :default ] )
      end
    end
  end
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
