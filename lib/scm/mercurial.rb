class Scm
  class Mercurial < Common
    def clone source, dest
      run %{hg clone --ssh "ssh -i #{ SSH::PRIVATE_KEY }" #{ source } #{ dest }}
    end
    alias clone_clone clone


    def update_commands_for target, server_ip, repository
      [ "cd #{ target } && hg pull --ssh 'ssh -l #{ whoami } -i #{ SSH::PRIVATE_KEY } #{ SSH::OPTIONS }'",
        "cd #{ target } && hg update" ]
    end


    def update target
      run "cd #{ target } && hg pull --ssh 'ssh -l #{ whoami } -i #{ SSH::PRIVATE_KEY } #{ SSH::OPTIONS }'"
      run "cd #{ target } && hg update"
    end


    def install_command target, server_ip, url
      "scp #{ SSH::OPTIONS } -r #{ whoami }@#{ server_ip }:#{ Configurator::Server.clone_clone_directory( url ) } #{ target }"
    end


    def mercurial?
      true
    end


    def to_s
      "Mercurial"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
