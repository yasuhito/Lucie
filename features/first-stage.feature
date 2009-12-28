Feature: First stage installer
  As a Lucie user
  I want to execute first stage installation
  So that I can proceed to second stage installation

  Background:
    Given node list is empty
    And eth0 "192.168.0.1"
    And a node named "yasuhito_node", with IP address "192.168.0.100"

  Scenario: run first stage installer
    When I run first stage installer with node "yasuhito_node"
    Then "Setting up hard disk partitions ..." displayed
    And "Setting up Linux base system ..." displayed
    And "Installing a kernel package ..." displayed
    And "Setting up grub ..." displayed
    And "Generating misc configurations ..." displayed
    And "Setting up ssh ..." displayed
