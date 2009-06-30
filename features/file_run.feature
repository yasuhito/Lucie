Feature: run commands

  As a Lucie module
  I want to run commands
  So that I can install nodes

  Background:
    Given a log file "/tmp/lucie.log"
    And a file "/tmp/lucie-test.tmp" not exist

  Scenario: run
    Given --verbose option is off
    When I run "touch /tmp/lucie-test.tmp"
    Then nothing raised
    And "/tmp/lucie-test.tmp" created
    And nothing displayed
    And nothing logged

  Scenario: run --verbose
    Given --verbose option is on
    When I run "touch /tmp/lucie.tmp"
    Then nothing raised
    And "/tmp/lucie.tmp" created
    And "touch /tmp/lucie.tmp" displayed
    And "touch /tmp/lucie.tmp" logged

  Scenario: run --dry-run
    Given --dry-run option is on
    When I run "touch /tmp/lucie-test.tmp"
    Then nothing raised
    And "/tmp/lucie-test.tmp" not created
    And "touch /tmp/lucie-test.tmp" displayed
    And "touch /tmp/lucie-test.tmp" logged

  Scenario: run --verbose --dry-run
    Given --verbose option is on
    And --dry-run option is on
    When I run "touch /tmp/lucie-test.tmp"
    Then nothing raised
    And "/tmp/lucie-test.tmp" not created
    And "touch /tmp/lucie-test.tmp" displayed
    And "touch /tmp/lucie-test.tmp" logged

  Scenario: run and fail
    When I run "false"
    Then an error "'false' failed." raised
