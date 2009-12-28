Feature: write files
  As a Lucie user
  I want to write files
  So that I can install nodes

  Background:
    Given Lucie log file is "/tmp/lucie.log"
    And a file "/tmp/lucie.tmp" not exist

  Scenario: write_file
    Given --verbose option is off
    When I write file "/tmp/lucie.tmp" with "Hello World"
    Then "/tmp/lucie.tmp" created
    And contents of "/tmp/lucie.tmp" is "Hello World"
    And nothing displayed
    And nothing logged

  Scenario: write_file --verbose
    Given --verbose option is on
    When I write file "/tmp/lucie.tmp" with "Hello World"
    Then "/tmp/lucie.tmp" created
    And contents of "/tmp/lucie.tmp" is "Hello World"
    And "file write (/tmp/lucie.tmp)" displayed
    And "> Hello World" displayed
    And "file write (/tmp/lucie.tmp)" logged
    And "> Hello World" logged

  Scenario: write_file --dry-run
    Given --dry-run option is on
    When I write file "/tmp/lucie.tmp" with "Hello World"
    Then "/tmp/lucie.tmp" not created
    And nothing displayed
    And nothing logged

  Scenario: write_file --dry-run (sudo)
    Given --dry-run option is on
    When I sudo write file "/tmp/lucie.tmp" with "Hello World"
    Then "/tmp/lucie.tmp" not created
    And nothing displayed
    And nothing logged

  Scenario: write_file --verbose --dry-run
    Given --verbose option is on
    And --dry-run option is on
    When I write file "/tmp/lucie.tmp" with "Hello World"
    Then "/tmp/lucie.tmp" not created
    And "file write (/tmp/lucie.tmp)" displayed
    And "> Hello World" displayed
    And "file write (/tmp/lucie.tmp)" logged
    And "> Hello World" logged

  Scenario: write_file --verbose --dry-run (sudo)
    Given --verbose option is on
    And --dry-run option is on
    When I write file "/tmp/lucie.tmp" with "Hello World"
    Then "/tmp/lucie.tmp" not created
    And "file write (/tmp/lucie.tmp)" displayed
    And "> Hello World" displayed
    And "file write (/tmp/lucie.tmp)" logged
    And "> Hello World" logged
