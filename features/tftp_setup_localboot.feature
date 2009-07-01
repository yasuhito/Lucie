Feature: Setup tftpd to boot from local disks
  As a Lucie user
  I want to setup tftp localboot automatically
  So that I have not to write configuration and restart tftpd by hand

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And node list is empty
  
  Scenario: Setup tftpd
    Given RUN_DAEMON option of tftpd default config is "YES"
    And command line option of default config is "-v -l -s /var/lib/tftpboot"
    And a node named "yasuhito_private_node00", with IP address "192.168.0.100"
    And a node named "yasuhito_private_node01", with IP address "192.168.0.101"
    And a node named "yasuhito_private_node02", with IP address "192.168.0.102"
    When I try to setup tftpd localboot for node "yasuhito_private_node01"
    Then PXE configuration file for node "yasuhito_private_node01" should be modified to boot from local
