require "ssh"


class FirstStage
  module SSH
    def ssh command
      ::SSH.new( @logger, @debug_options ).sh @node.name, command
    end


    def scp from, to
      ::SSH.new( @logger, @debug_options ).cp from, "root@#{ @node.name }:#{ to }"
    end


    def scp_back from, to
      ::SSH.new( @logger, @debug_options ).cp "root@#{ @node.name }:#{ from }", to
    end


    def scp_r from, to
      ::SSH.new( @logger, @debug_options ).cp_r from, "root@#{ @node.name }:#{ to }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
