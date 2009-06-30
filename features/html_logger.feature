Feature: HTML logger

  As a Lucie user
  I want to examine installation result easily with my web browser
  So that I can find failed node at a glance

  Background:
    Given node list is empty

  Scenario: auto refresh
    When html logger started
    Then html log refreshed automatically

  Scenario: update status
    Given a node named "yasuhito_node0"
    And a node named "yasuhito_node1"
    And html logger started
    When the node "yasuhito_node0" updated its status "Started"
    And the node "yasuhito_node1" updated its status "Hello"
    And the node "yasuhito_node0" updated its status "Installed"
    And the node "yasuhito_node0" updated its status "OK"
    And the node "yasuhito_node1" updated its status "Bye"
    Then status of "yasuhito_node0" is "OK"
    And status of "yasuhito_node1" is "Bye"
