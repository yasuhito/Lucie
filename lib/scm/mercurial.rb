module Scm
  class Mercurial < Common
    def clone url, target
      run %{hg clone --ssh "ssh -i #{ SSH::PRIVATE_KEY }" #{ url } #{ target }}
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
