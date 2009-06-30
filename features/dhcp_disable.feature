Feature: Disable dhcpd

  As a Lucie installer
  I want to stop dhcp service automatically
  So that Lucie users don't have to configure and stop dhcpd by hand

  Scenario: Disable dhcpd
    When I try to disable dhcpd
    Then dhcpd configuration file removed
    And dhcpd should be stopped
