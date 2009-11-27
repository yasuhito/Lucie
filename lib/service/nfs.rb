require "installer"
require "lucie/io"
require "lucie/log"
require "lucie/utils"
require "nodes"


class Service
  class Nfs < Service
    include Lucie::IO
    include Lucie::Utils


    config "/etc/exports"
    prerequisite "nfs-kernel-server"


    def setup nodes, installer
      info "Setting up nfsd ..."
      return if nodes.empty?
      backup
      write_config nodes, installer
      restart
    end


    ############################################################################
    private
    ############################################################################


    def write_config nodes, installer
      write_file @@config, exports_config( nodes, installer ), @debug_options.merge( :sudo => true ), @debug_options[ :messenger ]
    end


    def exports_entry_string node, installer
      return <<-EOF
# #{ node.name }
#{ installer.path } #{ node.ip_address }(async,ro,no_root_squash,no_subtree_check)
EOF
    end


    def exports_config nodes, installer
      lines = nodes.collect do | each |
        exports_entry_string each, installer
      end
      lines.join "\n"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
