module Scm
  class Git < Common
    def clone url, target
      run "git clone #{ url } #{ target }", { "GIT_SSH" => "ssh -i #{ SSH::PRIVATE_KEY }" }
    end


    def update target
      run "cd #{ target } && git pull", { "GIT_SSH" => "ssh -i #{ SSH::PRIVATE_KEY }" }
      run "cd #{ target } && git update", { "GIT_SSH" => "ssh -i #{ SSH::PRIVATE_KEY }" }
    end


    def install_command target, server_ip, url
      "git clone git://#{ server_ip }/#{ Configurator::Server.clone_directory( url ) } #{ target }"
    end


    def to_s
      "Git"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
