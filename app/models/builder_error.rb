class BuilderError < RuntimeError
  attr_reader :status

  def initialize(message, status = "error")
    super message
    @status = status
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
