Feature: Sort installers
  As a Lucie user
  I want to get a sorted list of installers
  So that I can list up installers in many ways

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And installers temporary directory "/tmp/lucie/tmp/installers" is empty

  Scenario: Sort by name
    Given an installer for suite "potato"
    And an installer for suite "etch"
    And an installer for suite "lenny"
    When I try to sort installers
    Then I should get a sorted installer list "etch, lenny, potato"
