require "first-stage/ssh"


class FirstStage
  class SSHKeys
    include SSH


    def initialize node, logger, debug_options = {}
      @node = node
      @logger = logger
      @debug_options = debug_options
    end


    def setup
      host_keys.each do | each |
        restore_or_backup local_key_path( each ), node_key_path( each )
      end
    end


    ############################################################################
    private
    ############################################################################


    def restore_or_backup local_key, node_key
      if FileTest.exists?( local_key )
        restore local_key, node_key
      else
        scp_back node_key, local_key
      end
    end


    def restore local_key, node_key
      scp local_key, node_key
      if /\.pub\Z/=~ node_key
        ssh "chmod 644 #{ node_key }"
      else
        ssh "chmod 600 #{ node_key }"
      end
    end


    def local_key_path key_name
      File.join Configuration.log_directory, @node.name, key_name
    end


    def node_key_path key_name
      File.join "/tmp/target/etc/ssh", key_name
    end


    def host_keys
      [ "ssh_host_dsa_key", "ssh_host_rsa_key", "ssh_host_dsa_key.pub", "ssh_host_rsa_key.pub" ]
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:

