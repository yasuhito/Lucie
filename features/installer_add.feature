Feature: add installer
  As a Lucie user
  I want to add an installer
  So that I can install nodes

  Background:
    Given Lucie log path is "/tmp/lucie.log"

  Scenario: add installer
    Given --verbose option is on
    And --dry-run option is on
    And suite is "lenny"
    When I add an installer
    Then temporary directory for the installer created
    And an installer added

