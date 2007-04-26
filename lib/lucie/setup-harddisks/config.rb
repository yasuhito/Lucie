# = setup-harddisks ディスク定義用ライブラリ
#
# Lucie リソース設定ファイル <code>/etc/lucie/partition.rb</code> の先頭でこのファイルを
# <code>require</code> すること。詳しくは <code>doc/example/partition.rb</code> を参照。
#
# $Id$
#
# Author::   Yoshiaki Sakae (mailto:sakae@is.titech.ac.jp)
# Revision:: $Revision$
# License::  GPL2

require 'lucie/setup-harddisks/partition'

# ------------------------- Convenience methods.

def partition ( label, &block )
  return Lucie::SetupHarddisks::Partition.new( label, &block )
end


### Local variables:
### mode: Ruby
### indent-tabs-mode: nil
### End:
