class ConfigurationUpdator
  class Client
    def initialize debug_options
      @debug_options = debug_options
    end


    def repository_name_for ip_address
      return "REPOSITORY" if @debug_options[ :dry_run ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
