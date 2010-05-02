require "lucie/debug"
require "lucie/utils"
require "service/config-manager"
require "service/prerequisite-checker"


module Service
  #
  # A base class for services
  #
  class Common
    include Lucie::Debug
    include Lucie::Utils


    attr_reader :config_path


    def self.prerequisite package
      PrerequisiteChecker.add_prerequisite self, package
    end


    def self.config path
      ConfigManager.instance.add self, path
    end


    def initialize debug_options = {}
      @debug_options = debug_options
      @config_path = @debug_options[ :config_path ] || ConfigManager.instance[ self.class ]
    end


    ##############################################################################
    private
    ##############################################################################


    def prerequisites
      PrerequisiteChecker.prerequisites_for self.class
    end


    def restart
      prerequisites.each do | each |
        init_script = "/etc/init.d/#{ each }"
        if dry_run || FileTest.exists?( init_script )
          run "sudo #{ init_script } restart", @debug_options
        end
      end
    end


    def backup
      if dry_run || FileTest.exists?( @config_path )
        run "sudo mv -f #{ @config_path } #{ @config_path }.old", @debug_options
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
