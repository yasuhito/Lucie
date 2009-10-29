class Scm
  class Git < Common
    def clone url, target
      run "git clone #{ url } #{ target }", { "GIT_SSH" => "ssh -i #{ SSH.private_key }" }
    end


    def update_commands_for target, server_ip, repository
      [ "cd #{ target } && git pull", "cd #{ target } && git update" ]
    end


    def update target
      test_installed
      run "cd #{ target } && git pull", { "GIT_SSH" => "ssh -i #{ SSH.private_key }" }
      run "cd #{ target } && git update", { "GIT_SSH" => "ssh -i #{ SSH.private_key }" }
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
