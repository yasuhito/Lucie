Feature: Remove nodes
  As a Lucie user
  I want to remove nodes
  So that I can keep my node list clean

  Background:
    Given node list is empty
    And Lucie log path is "/tmp/lucie.log"

  Scenario: Remove a node
    Given a node named "my_private_node"
    When I try to remove a node "my_private_node"
    Then a node named "my_private_node" removed

  Scenario: Remove nonexistent node
    When I try to remove a node "NO_SUCH_NODE"
    Then nothing raised
