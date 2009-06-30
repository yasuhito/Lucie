Feature: node update command
  As a Lucie user
  I want to update ldb on the Lucie client
  So that I can update node configurations

  Background:
   Given Lucie log path is "/tmp/lucie.log"
   And node list is empty
   And remote repository "ssh://my.repository.org//ldb"

  Scenario: node update
    Given local repository is empty
    And eth0 "192.168.0.1"
    And a node named "yasuhito_node0", with IP address "192.168.0.100"
    And a node named "yasuhito_node1", with IP address "192.168.0.101"
    And --dry-run option is on
    When I run node update "yasuhito_node0, yasuhito_node1"
    Then remote repository cloned to Lucie server
    And ldb on "yasuhito_node0" updated
    And ldb on "yasuhito_node0" executed

  Scenario: node update (second time)
    Given local repository already exists
    And eth0 "192.168.0.1"
    And a node named "yutaro_node0", with IP address "192.168.0.100"
    And a node named "yutaro_node1", with IP address "192.168.0.101"
    And --dry-run option is on
    When I run node update "yutaro_node0"
    Then ldb on Lucie server updated
    And ldb on "yutaro_node0" updated
    And ldb on "yutaro_node0" executed

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

