require "ssh"


class FirstStage
  module SSH
    def login
      ::SSH.new( @debug_options.merge( :logger => @logger ) ).login @node.name
    end


    def ssh command = nil
      ::SSH.new( @debug_options.merge( :logger => @logger ) ).sh @node.name, command
    end


    def scp from, to
      ::SSH.new( @debug_options.merge( :logger => @logger ) ).cp from, "root@#{ @node.name }:#{ to }"
    end


    def scp_back from, to
      ::SSH.new( @debug_options.merge( :logger => @logger ) ).cp "root@#{ @node.name }:#{ from }", to
    end


    def scp_r from, to
      ::SSH.new( @debug_options.merge( :logger => @logger ) ).cp_r from, "root@#{ @node.name }:#{ to }"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
