require "ssh"


class FirstStage
  module SSH
    def ssh command
      ::SSH.new( @debug_options ).sh @node.name, command, @logger
    end


    def scp from, to
      ::SSH.new( @debug_options ).cp from, "root@#{ @node.name }:#{ to }", @logger
    end


    def scp_back from, to
      ::SSH.new( @debug_options ).cp "root@#{ @node.name }:#{ from }", to, @logger
    end


    def scp_r from, to
      ::SSH.new( @debug_options ).cp_r from, "root@#{ @node.name }:#{ to }", @logger
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
