class ConfigurationUpdator
  class Server
    CLONE_CLONE_SUFFIX = ".local"


    def self.config_directory
      File.join Configuration.temporary_directory, "config"
    end


    def initialize debug_options = {}
      @debug_options = debug_options
    end


    def update repos_name
      scm_from( repos_name ).update local_clone_directory( repos_name )
      if mercurial_repository?( repos_name )
        scm_from( repos_name ).update local_clone_clone_directory( repos_name )
      end
    end


    ############################################################################
    private
    ############################################################################


    def local_clone_directory repos_name
      File.join self.class.config_directory, repos_name
    end


    def local_clone_clone_directory repos_name
      local_clone_directory( repos_name ) + CLONE_CLONE_SUFFIX
    end


    def scm_name
      { ".hg" => "Mercurial",
        ".svn" => "Subversion",
        ".git" => "Git" }
    end


    def mercurial_repository? repos_name
      scm_from( repos_name ).is_a? Scm::Mercurial
    end


    def scm_from repos_name
      Scm.from guess_scm_type( repos_name ), @debug_options
    end


    def guess_scm_type repos_name
      return @debug_options[ :scm ] if @debug_options[ :scm ]
      Dir.glob( File.join( local_clone_directory( repos_name ), ".*" ) ).each do | each |
        name = scm_name[ File.basename( each ) ]
        return name if name
      end
      nil
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
