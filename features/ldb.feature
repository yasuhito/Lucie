Feature: LDB

  As a Lucie installer
  I want to install and execute LDB on Lucie client nodes
  So that I can run second stage

  Background:
   Given remote repository "ssh://my.repository.org//ldb"
   And temporary directory "/tmp/lucie/tmp" is empty

  Scenario: update LDB
    Given eth0 "192.168.0.1"
    And a node named "yutaro_node", with IP address "192.168.0.100"
    When I update LDB on node "yutaro_node"
    Then LDB on "yutaro_node" updated

  Scenario: clone remote repository
    Given eth0 "192.168.0.1"
    And local repository is empty
    When I clone remote repository
    Then repository cloned to local

  Scenario: update local clone repository
    Given eth0 "192.168.0.1"
    And local repository already exists
    When I clone remote repository
    Then local repository updated

  Scenario: run LDB
    Given eth0 "192.168.0.1"
    And a node named "kosuke", with IP address "192.168.0.100"
    When I start LDB on node "kosuke"
    Then configurations updated on "kosuke"
