Feature: Size of installer list
  As a Lucie user
  I want to get the total number of installers
  So that I can count installers

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And installers temporary directory "/tmp/lucie/tmp/installers" is empty

  Scenario: Get size of the installer list
    Given an installer for suite "potato"
    And an installer for suite "etch"
    And an installer for suite "lenny"
    When I try to get a size of installer list
    Then the installer list size should be 3
