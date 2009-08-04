require "lucie/utils"


module Configurator
  class Server
    attr_writer :dpkg
    attr_reader :scm


    def self.config_directory
      File.join Configuration.temporary_directory, "config"
    end


    def self.clone_directory url
      File.join config_directory, Configurator.convert( url )
    end


    def self.clone_clone_directory url
      clone_directory( url ) + ".local"
    end


    def initialize scm = nil, options = {}
      @options = options
      @scm = Scm.from( scm, @options ) if scm
      @dpkg = Dpkg.new
    end


    def setup
      unless FileTest.exists?( Configuration.temporary_directory )
        Lucie::Utils.mkdir_p Configuration.temporary_directory, { :dry_run => @options[ :dry_run ], :verbose => @options[ :verbose ] }, @options[ :messenger ]
      end
    end


    def clone url
      raise "scm is not specified" unless @scm
      @scm.clone url, self.class.clone_directory( url )
    end


    def check_backend_scm
      return unless @scm
      raise "#{ @scm } is not installed" unless @dpkg.installed?( @scm.name )
    end


    ############################################################################
    private
    ############################################################################


    def messenger
      @options[ :messenger ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
