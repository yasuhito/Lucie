module Scm
  class Subversion < Common
    def clone url, target
      run "svn co #{ url } #{ target }", { "SVN_SSH" => "ssh -i #{ SSH::PRIVATE_KEY }" }
    end


    def clone_clone source, dest
      raise "local clone is not supported on Subversion"
    end


    def update target
      run "svn update #{ target }", { "SVN_SSH" => "ssh -i #{ SSH::PRIVATE_KEY }" }
    end


    def install_command target, server_ip, url
      "scp #{ SSH::OPTIONS } -r #{ server_ip }:#{ Configurator::Server.clone_directory( url ) } #{ target }"
    end


    def to_s
      "Subversion"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
