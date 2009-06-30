Feature: Teardown environment for install
  As a Lucie User
  I want to disable dhcp, nfs and tftp automatically when finished installation
  So that I have not to disable them by hand

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And installers temporary directory "/tmp/lucie/tmp/installers" is empty

  Scenario: teardown installation environment
    Given an installer for suite "potato"
    And eth0 "192.168.0.1"
    And a node named "yasuhito_private_node00", with IP address "192.168.0.100" and with MAC address "00:00:00:00:00:00"
    When I try to setup installation envrionemt for "yasuhito_private_node00" with installer "potato"
    And I try to teardown installation environment for "yasuhito_private_node00" with installer "yasuhito_installer"
    Then PXE configuration file for node "yasuhito_private_node00" should be modified to boot from local
    And nfsd configuration should not include an entry for node "yasuhito_private_node00"
    And dhcpd configuration should not include an entry for node "yasuhito_private_node00"
