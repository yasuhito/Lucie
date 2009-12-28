Feature: tftpd remove entry
  As a Lucie user
  I want to remove PXE setting files
  So that I can remove a node and related configurations completely

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And node list is empty
    And a node named "yasuhito_private_node00", with IP address "192.168.0.100"
    And a node named "yasuhito_private_node01", with IP address "192.168.0.101"
    And a node named "yasuhito_private_node02", with IP address "192.168.0.102"

  Scenario: remove an entry
    When I try to remove tftpd configuration for node "yasuhito_private_node01"
    Then PXE configuration file for node "yasuhito_private_node01" removed

