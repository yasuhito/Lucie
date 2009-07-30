module Scm
  class Subversion < Common
    def clone url, target
      run "svn co #{ url } #{ target }", { "SVN_SSH" => "ssh -i #{ SSH::PRIVATE_KEY }" }
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
