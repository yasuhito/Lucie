Feature: Setup approx

  As a Lucie installer
  I want to setup approx package proxy automatically
  So that users don't have to write approx configuration by hand
  
  Scenario: Setup approx
    When I try to setup approx
    Then an approx configuration file generated
    And the approx configuration file should include debian repository
    And the approx configuration file should include security repository
    And the approx configuration file should include volatile repository
    And approx restarted
