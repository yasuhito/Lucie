require "command/option-list"
require "getoptlong"


module Command
  class Option
    OPTIONS = {}


    def self.usage str
      OptionList.register_usage str
    end

    
    def self.add_option opt
      module_eval do | mod |
        if OPTIONS[ mod ]
          OPTIONS[ mod ] << opt
        else
          OPTIONS[ mod ] = [ opt ]
        end
        attr_accessor attr_name_of( opt[ :long_option ] ).intern
      end
    end


    def self.separator
      module_eval do | mod |
        OPTIONS[ mod ] << :separator
      end
    end


    def self.attr_name_of option # :nodoc:
      option.sub( /^--/, "" ).tr( "-", "_" )
    end


    # default options:
    attr_reader :dry_run
    attr_reader :help
    attr_reader :verbose


    def initialize
      OptionList.clear_options
      register_options
    end


    def parse argv
      old_argv = ARGV.dup
      begin
        ARGV.replace argv
        gopts = GetoptLong.new( *OptionList.options )
        gopts.quiet = true
        gopts.each do | opt, arg |
          instance_variable_set "@" + Option.attr_name_of( opt ), ( arg != "" ? arg : true )
          call_proc opt, arg
        end
      ensure
        ARGV.replace old_argv
      end
      self
    end


    def usage
      OptionList.usage
    end


    def check_mandatory_options
      options_without_separator.each do | each |
        next unless each[ :mandatory ]
        value = instance_variable_get( "@" + Option.attr_name_of( each[ :long_option ] ) )
        raise "#{ each[ :long_option ] } option is a mandatory." unless value
      end
      self
    end
    
    
    ##############################################################################
    private
    ##############################################################################


    def call_proc opt, arg
      options_without_separator.each do | each |
        if each[ :opt ] and each[ :proc ]
          each[ :proc ].call( arg )
        end
      end
    end


    def register_options
      options.each do | each |
        if each == :separator
          OptionList.push_separator
        else
          OptionList.register_options each[ :long_option ], each[ :short_option ], each[ :argument ], each[ :description ]
        end
      end
    end


    def options
      instance_eval do | obj |
        OPTIONS[ obj.class ]
      end
    end


    def options_without_separator
      instance_eval do | obj |
        OPTIONS[ obj.class ].select do | each |
          each != :separator
        end
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
