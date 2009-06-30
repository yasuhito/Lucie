Feature: Find nodes 
  As a Lucie user
  I want to find nodes
  So that I can load nodes which were previously added

  Background:
    Given node list is empty
    And Lucie log path is "/tmp/lucie.log"

  Scenario: find a node and no node found
    When I try to find a node "NO_SUCH_NODE"
    Then no node found

  Scenario: find a node
    Given a node named "my_private_node00"
    And a node named "my_private_node01"
    And a node named "my_private_node02"
    When I try to find a node "my_private_node01"
    Then a node named "my_private_node01" found

