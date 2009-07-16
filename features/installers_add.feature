Feature: Installer addition
  As a Lucie user
  I want to add an installer
  So that I can install nodes with this

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And installers temporary directory "/tmp/lucie/tmp/installers" is empty

  Scenario: Add an installer and examples generated
    When an installer for suite "potato"
    Then a directory for the installer should be created
    And configuration example for the installer should be generated
    And I can find a installer "potato_i386"

  Scenario: Overwrite old installer
    Given an installer for suite "potato"
    When an installer for suite "potato"
    Then the installer list size is 1
