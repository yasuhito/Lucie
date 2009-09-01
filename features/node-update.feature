# language: ja
機能: node update command

  As a Lucie user
  I want to update node configurations with 'node update' command
  So that I can keep node configurations up to date

  背景:
    前提 node list is empty
    かつ Lucie のテンポラリディレクトリは "/tmp/lucie"

  シナリオ: node update
    前提 Mercurial がインストールされている
    かつ バックエンドとして Mercurial を指定したサーバーコンフィグレータ
    かつ サーバーコンフィグレータが Lucie サーバに設定リポジトリ "ssh://my.repository.org//ldb" を複製
    かつ eth0 "192.168.0.1"
    かつ a node named "yutaro_node0", with IP address "192.168.0.100"
    かつ a node named "yutaro_node1", with IP address "192.168.0.101"
    もし I run node update "yutaro_node0, yutaro_node1"
    ならば nothing raised
    かつ ldb on Lucie server updated
    かつ ldb on "yutaro_node0" executed
    かつ ldb on "yutaro_node1" executed

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
