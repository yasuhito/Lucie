ChangesetEntry = Struct.new :operation, :file


class ChangesetEntry
  def to_s
    return "  #{ operation } #{ file }"
  end
end
