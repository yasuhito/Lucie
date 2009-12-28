Feature: node install command
  As a Lucie user
  I want to install a node with node install command
  So that I can install a node

  Background:
    Given eth0 "192.168.0.1"
    And a node named "yasuhito_private_node", with IP address "192.168.0.100"

  Scenario: node install
    Given --address option is "192.168.0.100"
    And --netmask option is "255.255.255.0"
    And --mac option is "11:22:33:44:55:66"
    And --storage-conf option is "my_storage.conf"
    And --verbose option is on
    When I run node install "yasuhito_private_node"
    Then node "yasuhito_private_node" installed
