class ConfigurationUpdator
  class Client
    def initialize debug_options
      @debug_options = debug_options
    end


    def repository_name_for node
      return @debug_options[ :repository_name ] if @debug_options[ :dry_run ] and @debug_options[ :repository_name ]
      raise "Configuration repository for #{ node.name } not found on Lucie server."
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
