Feature: Load nodes
  As a Lucie user
  I want to load nodes
  So that I can install nodes which were previously added

  Background:
    Given node list is empty
    And Lucie log path is "/tmp/lucie.log"

  Scenario: Load nodes (empty list)
    When I try to load nodes
    Then node list should be empty

  Scenario: Load nodes (1 node)
    Given a node named "yasuhito_node"
    When I try to load nodes
    Then node list should have exactly 1 node(s)
    And node list should include a node "yasuhito_node"

  Scenario: Load nodes (3 nodes)
    Given a node named "yasuhito_node0"
    And a node named "yasuhito_node1"
    And a node named "yasuhito_node2"
    When I try to load nodes
    Then node list should have exactly 3 node(s)
    And node list should include a node "yasuhito_node0"
    And node list should include a node "yasuhito_node1"
    And node list should include a node "yasuhito_node2"
