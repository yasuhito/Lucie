Feature: Size of node list
  As a Lucie user
  I want to get the total number of nodes
  So that I can count nodes

  Background:
    Given node list is empty
    And Lucie log path is "/tmp/lucie.log"

  Scenario: Get size of the node list
    Given a node named "my_private_node0"
    And a node named "my_private_node1"
    And a node named "my_private_node2"
    And I try to remove a node "my_private_node1"
    When I try to get a size of node list
    Then the node list size is 2
