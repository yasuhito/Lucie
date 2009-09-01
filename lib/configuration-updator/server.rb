require "configuration"
require "scm"


class ConfigurationUpdator
  class Server
    def initialize debug_options = {}
      @scm = Scm.new( debug_options )
    end


    def update repos_name
      scm = @scm.from( local_clone_directory( repos_name ) )
      scm.test_installed
      scm.update local_clone_directory( repos_name )
      scm.update local_clone_clone_directory( repos_name ) if scm.mercurial?
    end


    def local_clone_directory repos_name
      File.join config_directory, repos_name
    end


    ############################################################################
    private
    ############################################################################


    def config_directory
      File.join Configuration.temporary_directory, "config"
    end


    def local_clone_clone_directory repos_name
      local_clone_directory( repos_name ) + clone_clone_suffix
    end


    def clone_clone_suffix
      ".local"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
