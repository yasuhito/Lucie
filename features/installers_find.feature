Feature: Find installers
  As a Lucie user
  I want to find installers
  So that I can load installers which were previously added

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And installers temporary directory "/tmp/lucie/tmp/installers" is empty

  Scenario: find an installer and no node found
    When I try to find an installer "nosuch_installer"
    Then no installer found

  Scenario: find an installer
    Given an installer for suite "potato"
    Given an installer for suite "etch"
    Given an installer for suite "lenny"
    When I try to find an installer "etch"
    Then an installer "etch" loaded
