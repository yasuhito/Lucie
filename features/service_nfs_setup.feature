Feature: Setup nfsd to export nfsroot
  As a Lucie user
  I want to setup nfsd automatically
  So that I have not to write configuration and restart nfsd by hand

  Background:
    Given node list is empty
    And installers temporary directory "/tmp/lucie/tmp/installers" is empty
    And an installer for suite "lenny", arch "i386"

  Scenario: Setup nfsd for one node
    And a node named "yasuhito_private_node00", with IP address "192.168.0.100"
    When I try to setup nfsd for installer "lenny_i386"
    Then nfsd configuration includes an entry for node "yasuhito_private_node00"
    And nfsd should reload the new configuration

  Scenario: Setup nfsd for three nodes
    And a node named "yasuhito_private_node00", with IP address "192.168.0.100"
    And a node named "yasuhito_private_node01", with IP address "192.168.0.101"
    And a node named "yasuhito_private_node02", with IP address "192.168.0.102"
    When I try to setup nfsd for installer "lenny_i386"
    Then nfsd configuration includes an entry for node "yasuhito_private_node00"
    And nfsd configuration includes an entry for node "yasuhito_private_node01"
    And nfsd configuration includes an entry for node "yasuhito_private_node02"
    And nfsd should reload the new configuration

  Scenario: Setup nfsd with no node
    When I try to setup nfsd for installer "lenny_i386"
    Then nfsd configuration should have no entry
    And nfsd should not be refreshed
