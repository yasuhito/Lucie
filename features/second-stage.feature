Feature: Setup second stage environment

  As a Lucie installer
  I want to disable network boot
  So that I can start second stage installer

  Scenario: start second stage
    Given a node named "yasuhito00" with MAC address "11:22:33:44:55:66"
    When I try to start second stage for node "yasuhito00"
    Then network boot is disabled for a node with MAC address "11:22:33:44:55:66"
