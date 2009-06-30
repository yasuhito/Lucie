Feature: First stage installer
  As a Lucie user
  I want to execute first stage installation
  So that I can proceed to second stage installation

  Background:
    Given node list is empty

  Scenario: run first stage installer
    Given a node named "yasuhito_node"
    When I run first stage installer with node "yasuhito_node"
    Then "Setting up hard disk partitions ..." displayed
    And "Setting up Linux base system ..." displayed
    And "Installing a kernel package ..." displayed
    And "Setting up grub ..." displayed
    And "Generating misc configurations ..." displayed
    And "Setting up ssh ..." displayed
