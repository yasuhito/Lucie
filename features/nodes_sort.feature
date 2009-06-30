Feature: Sort nodes
  As a Lucie user
  I want to get a sorted list of nodes
  So that I can list up nodes in many ways

  Background:
    Given node list is empty
    And Lucie log path is "/tmp/lucie.log"

  Scenario: Sort by name
    Given a node named "my_private_node1"
    And a node named "my_private_node0"
    And a node named "my_private_node2"
    When I try to sort nodes by name
    Then I should get a sorted node list "my_private_node0, my_private_node1, my_private_node2"
