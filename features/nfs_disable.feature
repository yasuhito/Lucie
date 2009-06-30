Feature: Disable nfsd
  As a Lucie user
  I want to stop nfs service automatically
  So that I have not to remove configuration and stop nfsd by hand

  Background:
    Given node list is empty
    And Lucie log path is "/tmp/lucie.log"
    And installers directory "/tmp/lucie/tmp/installers" is empty

  Scenario: Remove configuration file and stop nfsd
    Given an installer for suite "lenny"
    And a node named "yasuhito_private_node00", with IP address "192.168.0.100"
    When I try to setup nfsd for installer "lenny"
    And I try to disable nfsd
    Then nfsd config file removed
    And nfsd stopped
