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
      File.join Configurator::Server.config_directory, repos_name
    end


    ############################################################################
    private
    ############################################################################


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
