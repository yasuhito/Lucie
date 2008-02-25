ChangesetEntry = Struct.new :operation, :file


class ChangesetEntry
  def to_s
    return "  #{ operation } #{ file }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
