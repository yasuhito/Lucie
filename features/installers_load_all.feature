Feature: Load installers
  As a Lucie user
  I want to load installers
  So that I can use installers which were previously added

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And installers temporary directory "/tmp/lucie/tmp/installers" is empty

  Scenario: Load installers (empty list)
    When I try to load installers
    Then installer list should be empty

  Scenario: Load installers (1 installer)
    Given an installer for suite "potato"
    When I try to load installers
    Then installer list has exactly 1 installer(s)
    And installer list includes a installer "potato"

  Scenario: Load installers (3 installers)
    Given an installer for suite "potato"
    And an installer for suite "etch"
    And an installer for suite "lenny"
    When I try to load installers
    Then installer list has exactly 3 installer(s)
    And installer list includes a installer "potato"
    And installer list includes a installer "etch"
    And installer list includes a installer "lenny"
