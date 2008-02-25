module Lucie
  module Config
    # すべてのリソースクラス
    # * ホスト (Host)
    # * ホストグループ (HostGroup)
    # * パッケージサーバ (PackageServer)
    # * DHCP サーバ (DHCPServer)
    # * インストーラ (Installer)
    # の親となるクラス。
    #
    # 子となるリソースクラスは、以下のクラス変数を持つ必要がある
    # * 登録されているリソースオブジェクトのリスト: <code>@@list = []</code>
    # * アトリビュート名のリスト: <code>@@required_attributes = []</code>
    # * すべてのアトリビュート名とデフォルト値のリスト: <code>@@attributes = []</code>
    # * アトリビュート名からデフォルト値へのマッピング: <code>@@default_value = {}</code>
    #
    class Resource  
      # ------------------------- Convenience class methods.

      # 登録されているリソースをクリアする
      public
      def self.clear
        module_eval %-
          @@list.clear
        -
      end

      # 属性の名前を返す
      public
      def self.attribute_names
        module_eval %-
          @@attributes.map { |name, default| name }
        -
      end
      
      # <code>[属性, デフォルト値]</code> の配列を返す
      public
      def self.attribute_defaults
        module_eval %-
          @@attributes.dup
        -
      end
      
      # 属性 <code>name</code> に対応するデフォルト値を返す
      public
      def self.default_value( name )
        module_eval %-
          @@default_value[:#{name}]
        -
      end
      
      # 必須属性を返す
      public
      def self.required_attributes
        module_eval %-
          @@required_attributes.dup
        -
      end
      
      # 属性 <code>name</code> が必須属性であるかどうかを返す
      public
      def self.required_attribute?( name )
        module_eval %-
          @@required_attributes.include? :#{name}
        -
      end
      
      # ------------------------- Infrastructure class methods.

      # 登録されているリソースを <code>key</code> で探す
      public
      def self.[](key)
        module_eval %-
          @@list['#{key}']
        -
      end
      
      # 登録されているリソースを返す
      public
      def self.list
        module_eval %-
          @@list
        -
      end
      
      # 属性を定義する
      public
      def self.attribute( name, default=nil )
        if default.nil?
          module_eval %-
            if !@@attributes.assoc(name)
              @@attributes << [:#{name}, nil]
              @@default_value[:#{name}] = nil
            end
          -
        else
         module_eval %-
            @@attributes << [:#{name}, '#{default}']
            @@default_value[:#{name}] = '#{default}'
          -
        end
        attr_accessor name
      end
      
      # 必須属性を定義する
      public
      def self.required_attribute( *args )
        module_eval %-
          @@required_attributes << :#{args.first}
        -
        attribute( *args )
      end      
            
      # 属性の中にはアクセスされたときに特別な動作を要求するものがある。
      # このメソッドで動作を設定できる。
      def self.overwrite_accessor(name, &block)
        remove_method name
        define_method(name, &block)
      end   
      
      # 新しいリソースオブジェクトを返す
      public
      def initialize # :yield: self
        set_default_values        
        yield self if block_given?
        register
      end
      
      # リソースの文字列表現を返す
      public
      def to_s
        if @alias
          return "#{@name} (#{@alias})"
        else
          return name
        end
      end
      
      # すべての属性にデフォルト値をセットする。
      # セットはアクセッサメソッドを通じて行われるため、アクセッサに設定された
      # 特別な処理もあわせて実行される。また、それぞれのインスタンスがたとえば
      # 独自の空 Array を持つように、デフォルト値のコピーを使う。     
      private
      def set_default_values
        self.class.attribute_defaults.each do |attribute, default|
          self.send "#{attribute}=", copy_of(default)
        end
      end
      
      private
      def register
        self.class.list[name] = self
      end
      
      # 即値以外はオブジェクトを dup する
      private
      def copy_of(obj)
        case obj
        when Numeric, Symbol, true, false, nil then obj
        else obj.dup
        end
      end
    end
    
    class InvalidAttributeException < ::Exception; end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
