Feature: node update command

  As a Lucie user
  I want to update node configurations with 'node update' command
  So that I can keep node configurations up to date

  Background:
   Given node list is empty
   And temporary directory "/tmp/lucie" is empty
   And remote hg repository "ssh://my.repository.org//ldb"

  Scenario: node update
    Given local hg repository already exists
    And eth0 "192.168.0.1"
    And a node named "yutaro_node0", with IP address "192.168.0.100"
    And a node named "yutaro_node1", with IP address "192.168.0.101"
    And the hg repository already cloned to "yutaro_node0"
    And --dry-run option is on
    When I run node update "yutaro_node0, yutaro_node1"
    Then nothing raised
    And ldb on Lucie server updated
    And "LDB updated on node yutaro_node0." displayed
    And "LDB updated on node yutaro_node1." displayed
    And ldb on "yutaro_node0" executed
    And ldb on "yutaro_node1" executed

  Scenario: fail to resolve IP address
    Given a node named "no_such_node"
    And --dry-run option is off
    When I run node update "no_such_node"
    Then an error "no address for no_such_node" raised

  Scenario: fail to determine network interface
    Given a node named "kosuke_node", with IP address "192.168.0.100"
    And eth0 "172.16.47.1"
    And --dry-run option is on
    When I run node update "kosuke_node"
    Then an error "cannot find network interface for kosuke_node" raised

