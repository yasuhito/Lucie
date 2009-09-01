# language: ja
機能: node update command

  As a Lucie user
  I want to update node configurations with 'node update' command
  So that I can keep node configurations up to date

  背景:
    前提 node list is empty
    かつ Lucie のテンポラリディレクトリは "/tmp/lucie"

  シナリオ: node update
    前提 Lucie クライアント "yasuhito_node" 用の設定リポジトリ (Mercurial)
      かつ コンフィグレータがその設定リポジトリを Lucie サーバに複製
      かつ コンフィグレータがその設定リポジトリを Lucie サーバ上でローカルに複製
      かつ Mercurial が Lucie サーバにインストールされている
   もし I run node update "yasuhito_node"
   ならば nothing raised
     かつ ldb on "yasuhito_node" executed

#   Scenario: fail to resolve IP address
#     Given a node named "no_such_node"
#     And --dry-run option is off
#     When I run node update "no_such_node"
#     Then an error "no address for no_such_node" raised

#   Scenario: fail to determine network interface
#     Given a node named "kosuke_node", with IP address "192.168.0.100"
#     And eth0 "172.16.47.1"
#     And --dry-run option is on
#     When I run node update "kosuke_node"
#     Then an error "cannot find network interface for kosuke_node" raised
