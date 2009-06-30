Feature: Setup environment for installation
  As a Lucie User
  I want to setup dhcp, nfs and tftp automatically when installing nodes
  So that I don't have to write configuration and restart them by hand

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And installers temporary directory "/tmp/lucie/tmp/installers" is empty

  Scenario: Setup installation environment
    And an installer for suite "potato"
    And RUN_DAEMON option of tftpd default config is "NO"
    And command line option of default config is "-l -s /var/lib/tftpboot"
    And eth0 "192.168.0.1"
    And a node named "yasuhito_node00", with IP address "192.168.0.100" and with MAC address "00:00:00:00:00:00"
    When I try to setup installation envrionemt for "yasuhito_node00" with installer "potato"
    Then "tftpd config generated?" is "YES"
    And PXE configuration file for node "yasuhito_node00" should be generated
    And "tftpd restarted?" is "YES"
    And nfsd configuration includes an entry for node "yasuhito_node00"
    And nfsd should reload the new configuration
    And dhcpd configuration should include an entry for node "yasuhito_node00"
    And dhcpd should reload the new configuration
