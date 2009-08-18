require "dpkg"
require "lucie/utils"
require "scm"


class Configurator
  class Server
    attr_writer :dpkg
    attr_reader :scm


    def self.config_directory
      File.join Configuration.temporary_directory, "config"
    end


    def self.clone_directory url
      File.join config_directory, Configurator.repository_name_from( url )
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
      unless FileTest.exists?( self.class.config_directory )
        Lucie::Utils.mkdir_p self.class.config_directory, { :dry_run => @options[ :dry_run ], :verbose => @options[ :verbose ] }, @options[ :messenger ]
      end
    end


    def clone url
      raise "scm is not specified" unless @scm
      @scm.clone url, self.class.clone_directory( url )
    end


    def clone_clone url, lucie_ip
      repos = self.class.clone_directory( url )
      if @scm.is_a?( Scm::Mercurial )
        @scm.clone "ssh://#{ lucie_ip }/#{ repos }", repos + ".local"
      else
        raise "local clone-clone is not supported on #{ @scm }"
      end
    end


    def update repository_name
      @scm.update File.join( self.class.config_directory, repository_name )
      if @scm.is_a?( Scm::Mercurial )
        @scm.update File.join( self.class.config_directory, repository_name ) + ".local"
      end
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
