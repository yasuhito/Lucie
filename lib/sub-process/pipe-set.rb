class PipeSet
  attr_reader :stdin
  attr_reader :stdout
  attr_reader :stderr


  def initialize stdin, stdout, stderr
    @stdin = stdin
    @stdout = stdout
    @stderr = stderr
  end


  def close
    [ @stdin, @stdout, @stderr ].each do | each |
      unless each.closed?
        each.close
      end
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
