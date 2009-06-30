Feature: Setup first stage environment

  As a Lucie installer
  I want to enable approx, tftp, nfs and dhcp for network boot
  So that I can start first stage installer

  Scenario: setup first stage environment
    Given eth0 "192.168.0.1"
    And a node named "yutaro", with IP address "192.168.0.100"
    When I try to setup first stage environment for node "yutaro"
    Then "Setting up installer ..." displayed
    And "Setting up approx ..." displayed
    And "Setting up tftpd ..." displayed
    And "Setting up nfsd ..." displayed
    And "Setting up dhcpd ..." displayed

