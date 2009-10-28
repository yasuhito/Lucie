require "configuration"
require "scm"


class ConfigurationUpdator
  class Server
    def initialize debug_options = {}
      @scm = Scm.new( debug_options )
    end


    def update repos_name
      begin
        test_local_clone_exists? repos_name
        scm = @scm.from( local_clone_directory( repos_name ) )
        scm.test_installed
        scm.update local_clone_directory( repos_name )
      rescue => e
        raise "Failed to update #{ local_clone_directory repos_name }: #{ e.message }"
      end
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


    def test_local_clone_exists? repos_name
      unless FileTest.directory?( local_clone_directory( repos_name ) )
        raise "Configuration repository #{ local_clone_directory repos_name } not found on Lucie server."
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
