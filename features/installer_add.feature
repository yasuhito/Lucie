Feature: add installer

  As a Lucie installer
  I want to add an installer
  So that I can install nodes

  Background:
    Given installers temporary directory is "/tmp/lucie/"

  Scenario: add installer
    Given --verbose option is on
    And --dry-run option is on
    And suite is "lenny"
    When I add an installer
    Then temporary directory for the installer created
    And installer configuration file for "lenny" generated

