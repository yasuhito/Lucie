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
    Given an installer for suite "potato", arch "i386"
    Given an installer for suite "etch", arch "i386"
    Given an installer for suite "lenny", arch "i386"
    When I try to find an installer "etch_i386"
    Then an installer "etch_i386" loaded
