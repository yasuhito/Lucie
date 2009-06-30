Feature: remove files
  As a Lucie user
  I want to remove files
  So that I can install nodes

  Background:
    Given a log file "/tmp/lucie.log"
    And a file "/tmp/lucie.tmp" exists

  Scenario: rm -f
    Given --verbose option is off
    When I execute rm -f "/tmp/lucie.tmp"
    Then "/tmp/lucie.tmp" removed
    And nothing displayed
    And nothing logged

  Scenario: rm -f --verbose
    Given --verbose option is on
    When I execute rm -f "/tmp/lucie.tmp"
    Then "/tmp/lucie.tmp" removed
    And "rm -f /tmp/lucie.tmp" displayed
    And "rm -f /tmp/lucie.tmp" logged

  Scenario: rm -f --dry-run
    Given --dry-run option is on
    When I execute rm -f "/tmp/lucie.tmp"
    Then "/tmp/lucie.tmp" not removed
    And "rm -f /tmp/lucie.tmp" displayed
    And "rm -f /tmp/lucie.tmp" logged

  Scenario: rm -f --verbose --dry-run
    Given --verbose option is on
    And --dry-run option is on
    When I execute rm -f "/tmp/lucie.tmp"
    Then "/tmp/lucie.tmp" not removed
    And "rm -f /tmp/lucie.tmp" displayed
    And "rm -f /tmp/lucie.tmp" logged
