Feature: mkdir
  As a Lucie user
  I want to make directories
  So that I can install nodes

  Background:
    Given a log file "/tmp/lucie.log"
    And a directory "/tmp/lucie" not exist

  Scenario: mkdir
    Given --verbose option is off
    When I execute mkdir "/tmp/lucie"
    Then directory "/tmp/lucie" created
    And nothing displayed
    And nothing logged

  Scenario: mkdir --verbose
    Given --verbose option is on
    When I execute mkdir "/tmp/lucie"
    Then directory "/tmp/lucie" created
    And "mkdir -p /tmp/lucie" displayed
    And "mkdir -p /tmp/lucie" logged

  Scenario: mkdir --dry-run
    Given --dry-run option is on
    When I execute mkdir "/tmp/lucie"
    Then directory "/tmp/lucie" not created
    And "mkdir -p /tmp/lucie" displayed
    And "mkdir -p /tmp/lucie" logged

  Scenario: mkdir --verbose --dry-run
    Given --verbose option is on
    And --dry-run option is on
    When I execute mkdir "/tmp/lucie"
    Then directory "/tmp/lucie" not created
    And "mkdir -p /tmp/lucie" displayed
    And "mkdir -p /tmp/lucie" logged
