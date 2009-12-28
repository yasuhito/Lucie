Feature: touch files

  As a Lucie sub-module
  I want to touch files
  So that I can install nodes

  Background:
    Given Lucie log file is "/tmp/lucie.log"
    And a file "/tmp/lucie.tmp" not exist

  Scenario: touch
    Given --verbose option is off
    When I execute touch "/tmp/lucie.tmp"
    Then "/tmp/lucie.tmp" created
    And nothing displayed
    And nothing logged

  Scenario: touch --verbose
    Given --verbose option is on
    When I execute touch "/tmp/lucie.tmp"
    Then "/tmp/lucie.tmp" created
    And "touch /tmp/lucie.tmp" displayed
    And "touch /tmp/lucie.tmp" logged

  Scenario: touch --dry-run
    Given --dry-run option is on
    When I execute touch "/tmp/lucie.tmp"
    Then "/tmp/lucie.tmp" not created
    And nothing displayed
    And nothing logged

  Scenario: touch --verbose --dry-run
    Given --verbose option is on
    And --dry-run option is on
    When I execute touch "/tmp/lucie.tmp"
    Then "/tmp/lucie.tmp" not created
    And "touch /tmp/lucie.tmp" displayed
    And "touch /tmp/lucie.tmp" logged
