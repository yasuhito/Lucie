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
      generate_config_file nodes, installer
      restart
    end


    def disable
      run "sudo rm -f #{ @@config }", @options, @messenger
      run "sudo /etc/init.d/nfs-kernel-server stop", @options, @messenger
    end


    ############################################################################
    private
    ############################################################################


    def generate_config_file nodes, installer
      @options[ :sudo ] = true
      backup
      write_file @@config, exports_config( nodes, installer ), @options, @messenger
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