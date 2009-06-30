Feature: Run installation
  As a Lucie user
  I want to start installation
  So that I can finish installation automatically

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And installers temporary directory "/tmp/lucie/tmp/installers" is empty

  Scenario: Run installation
    Given eth0 "192.168.0.1"
    When I try to install the node "yasuhito_private_node"
    Then harddisk paratitioned
    And a base system extracted
    And GRUB configured
    And network settings generated
    And a default password configured
    And SSH configured

