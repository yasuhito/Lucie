Feature: setup ssh
  As a Lucie user
  I want to install nodes via ssh
  So that I can log installer outputs via ssh

  Background:
    Given the rake task list cleared

  Scenario: setup ssh
    Given Lucie log path is "/tmp/lucie.log"
    And target directory is "/tmp/nfsroot"
    When I try to setup ssh
    Then ssh access to nfsroot configured

