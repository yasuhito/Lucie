#
# $Id$
#
# Author:: Yasuhito Takamiya (mailto:yasuhito@gmail.com)
# Revision:: $LastChangedRevision$
# License:: GPL2


ChangesetEntry = Struct.new :operation, :file


class ChangesetEntry
  def to_s
    return "  #{ operation } #{ file }"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
