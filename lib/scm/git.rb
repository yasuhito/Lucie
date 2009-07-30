module Scm
  class Git < Common
    def clone url, target
      run "git clone #{ url } #{ target }", { "GIT_SSH" => "ssh -i #{ SSH::PRIVATE_KEY }" }
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
