require 'English'
require 'lucie/setup-harddisks/const'

module Lucie
  module SetupHarddisks
    class OldPartition < Lucie::Config::Resource
      #TODO: 大部分が Partition と共通。スーパークラスとしてくくりだすべきだが、
      #@@list などのクラス変数も共有されてしまうため、整理が必要。

      # 登録されている Partition のリスト
      @@list = {}

      # アトリビュート名のリスト: [:name, :version, ...]
      @@required_attributes = []

      # _すべての_ アトリビュート名とデフォルト値のリスト: [[:name, nil], [:version, '0.0.1'], ...]
      @@attributes = [[:bootable, false], [:not_aligned, false]]

      # アトリビュート名からデフォルト値へのマッピング
      @@default_value = {}

      # Same as :attribute, but ensures that values assigned to the
      # attribute are array values by applying :to_a to the value.
      def self.array_attribute(name)
        @@attributes << [name, []]
        module_eval %{
          def #{name}
              @#{name} ||= []
            end
          def #{name}=(value)
              @#{name} = value.to_a
            end
        }
      end

      required_attribute :name          # partition name. e.g. usr, home, ...
      required_attribute :slice         # slice name, e.g. hda1, sdb2
      required_attribute :kind          # primary | logical
      required_attribute :fs            # swap|ext2|ext3|reiserfs|xfs|fat16|fat32
      required_attribute :size          # 100, (10...90)
      required_attribute :max_size
      required_attribute :min_size
      required_attribute :bootable      # true | false
      required_attribute :mount_point   # /, /usr, ..., none
      array_attribute    :mount_option  # rw, nosuid, ...

      required_attribute :start_sector
      required_attribute :end_sector
      required_attribute :start_unit
      required_attribute :end_unit
      required_attribute :not_aligned
      required_attribute :id            # Partition ID is determined based on fs
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
