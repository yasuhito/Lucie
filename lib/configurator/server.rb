require "dpkg"
require "lucie/utils"
require "scm"


class Configurator
  class Server
    CLONE_CLONE_SUFFIX = ".local"


    attr_writer :custom_dpkg # :nodoc:
    attr_reader :scm # :nodoc:


    def self.config_directory
      File.join Configuration.temporary_directory, "config"
    end


    def self.clone_directory url
      File.join config_directory, Configurator.repository_name_from( url )
    end


    def self.clone_clone_directory url
      clone_directory( url ) + CLONE_CLONE_SUFFIX
    end


    def initialize scm = nil, debug_options = {}
      @debug_options = debug_options
      @scm = Scm.from( scm, @debug_options ) if scm
    end


    def clone url
      create_config_directory unless config_directory_exists?
      scm_clone :from => url, :to => clone_directory_for( url )
    end


    def clone_clone url, lucie_ip
      return unless mercurial?
      local_clone = "ssh://#{ lucie_ip }/#{ clone_directory_for( url ) }"
      local_clone_clone = clone_clone_directory_for( url )
      scm_clone :from => local_clone, :to => local_clone_clone
    end


    def update repos_name
      scm_update local_clone_directory( repos_name )
      scm_update local_clone_clone_directory( repos_name ) if mercurial?
    end


    ############################################################################
    private
    ############################################################################


    # SCM operations ###########################################################


    def scm_clone from_to
      check_scm
      @scm.clone from_to[ :from ], from_to[ :to ]
    end


    def scm_update target
      check_scm
      @scm.update target
    end


    def check_scm
      raise "scm is not specified" unless @scm
      raise "#{ @scm } is not installed" unless scm_installed?
    end


    def scm_installed?
      if @custom_dpkg
        @custom_dpkg.installed?( @scm.name )
      else
        @debug_options[ :dry_run ] || Dpkg.new.installed?( @scm.name )
      end
    end


    def mercurial?
      @scm.is_a? Scm::Mercurial
    end


    # Paths ####################################################################


    def clone_directory_for url
      self.class.clone_directory url
    end


    def clone_clone_directory_for url
      self.class.clone_clone_directory url
    end


    def local_clone_directory repository_name
      File.join self.class.config_directory, repository_name
    end


    def local_clone_clone_directory repository_name
      local_clone_directory( repository_name ) + CLONE_CLONE_SUFFIX
    end


    def config_directory_exists?
      FileTest.exists? self.class.config_directory
    end


    def create_config_directory
      Lucie::Utils.mkdir_p self.class.config_directory, debug_options
    end


    # Debug ####################################################################


    def debug_options
      { :dry_run => @debug_options[ :dry_run ],
        :verbose => @debug_options[ :verbose ],
        :messenger => @debug_options[ :messenger ] }
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
