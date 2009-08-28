Feature: Setup dhcpd

  As a Lucie installer
  I want to setup dhcpd automatically
  So that Lucie users don't have to configure and restart dhcpd by hand

  Background: 
    Given node list is empty
    And eth0 "192.168.0.1"

  Scenario: Setup dhcpd for 1 node
    Given a node named "yasuhito00", with IP address "192.168.0.100"
    When I try to setup dhcpd
    Then dhcpd configuration should include 1 node(s)
    And dhcpd configuration should include an entry for node "yasuhito00"
    And dhcpd should reload the new configuration

  Scenario: Setup dhcpd for 3 nodes
    Given a node named "yasuhito00", with IP address "192.168.0.100"
    And a node named "yasuhito01", with IP address "192.168.0.101"
    And a node named "yasuhito02", with IP address "192.168.0.102"
    When I try to setup dhcpd
    Then dhcpd configuration should include 3 node(s)
    And dhcpd configuration should include an entry for node "yasuhito00"
    And dhcpd configuration should include an entry for node "yasuhito01"
    And dhcpd configuration should include an entry for node "yasuhito02"
    And dhcpd should reload the new configuration

  Scenario: No network interface found error
    Given a node named "yasuhito00", with IP address "172.16.47.100"
    When I try to setup dhcpd
    Then an error "No suitable network interface for installation found" raised

  Scenario: Setup dhcpd with no node and nothing happens
    When I try to setup dhcpd
    Then dhcpd configuration should not include node entry
    And dhcpd should not reload configuration
