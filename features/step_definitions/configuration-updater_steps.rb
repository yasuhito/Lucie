# -*- coding: utf-8 -*-
Given /^Lucie クライアント "([^\"]*)" 用の設定リポジトリ \(([a-zA-Z]+)\) が Lucie サーバ上に複製されている$/ do | name, scm |
  Given %{Lucie クライアント "#{ name }"}
  @scm = scm
end


Given /^コンフィグレーションアップデータがノード "([^\"]*)" の更新のために Lucie サーバの更新を実行した$/ do | name |
  @messenger = StringIO.new
  @updator = ConfigurationUpdator.new( debug_options )
  @updator.update_server_for [ Nodes.find( name ) ]
end


### Local variables:
### mode: Ruby
### coding: utf-8
### indent-tabs-mode: nil
### End:
