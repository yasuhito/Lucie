require "scm"


class ConfigurationUpdator
  class Server
    def initialize debug_options = {}
      @debug_options = debug_options
    end


    def update repos_name
      begin
        target = local_clone_directory( repos_name )
        unless FileTest.directory?( target )
          raise "Configuration repository #{ target } not found on Lucie server."
        end
        scm = Scm.new( @debug_options ).from( target )
        scm.test_installed
        scm.update target
      rescue => e
        raise "Failed to update #{ target }: #{ e.message }"
      end
    end


    def local_clone_directory repos_name
      File.join Configurator::Server.config_directory, repos_name
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
