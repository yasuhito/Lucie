Feature: setup nfsroot

  As a Lucie install command
  I want to setup ssh access to nfsroot
  So that I can spawn installation jobs to Lucie clients

  Scenario: setup ssh
    Given nfsroot directory is "/tmp/nfsroot"
    When I try to setup ssh
    Then ssh access to nfsroot configured

