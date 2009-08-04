module Scm
  class Mercurial < Common
    def clone url, target
      run %{hg clone --ssh "ssh -i #{ SSH::PRIVATE_KEY }" #{ url } #{ target }}
    end


    def update target
      run %{hg update --ssh "ssh -i #{ SSH::PRIVATE_KEY }" #{ target }}
    end


    def update_command
      "hg pull && hg update"
    end


    def install_command target, server_ip, url
      "scp #{ SSH::OPTIONS } -r #{ server_ip }:#{ Configurator::Server.clone_clone_directory( url ) } #{ target }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
