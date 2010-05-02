require "lucie/debug"
require "singleton"


module Service
  #
  # tests prerequisite packages
  #
  class PrerequisiteChecker
    #
    # prerequisite package list
    #
    class List
      include Singleton


      def initialize
        @list = Hash.new( [] )
      end


      def add service, package
        @list[ service ] = @list[ service ] + [ package ]
      end


      def [] service
        @list[ service ]
      end
    end


    include Lucie::Debug


    def self.prerequisites_for service
      List.instance[ service ]
    end


    def self.add_prerequisite service, package
      List.instance.add service, package
    end


    def initialize debug_options = {}
      @debug_options = debug_options
    end


    def missing_packages_for services
      missing_packages = all_prerequisites_for( services ).collect do | each |
        installed?( each ) ? nil : each
      end
      missing_packages.compact
    end


    ############################################################################
    private
    ############################################################################


    def all_prerequisites_for services
      all = services.collect do | each |
        self.class.prerequisites_for each
      end
      all.flatten
    end


    def installed? package
      Dpkg.new( @debug_options ).installed? package
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
