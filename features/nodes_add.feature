Feature: Node addition
  As a Lucie user
  I want to add a node
  So that I can install the node later

  Background:
    Given node list is empty
    And Lucie log path is "/tmp/lucie.log"

  Scenario: Add a node and find it
    When a node named "my_private_node"
    Then I can find a node named "my_private_node"

  Scenario: Overwrite old node
    Given a node named "super_node", with IP address "192.168.0.100"
    When a node named "super_node", with IP address "192.168.0.200"
    Then the node list size is 1
    And I can find a node named "super_node"
    And IP address of node "super_node" is "192.168.0.200"
