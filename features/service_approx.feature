Feature: Setup approx

  As a Lucie installer
  I want to setup approx package proxy automatically
  So that users don't have to write configuration and restart approx by hand
  
  Scenario: setup approx
    When I try to setup approx
    Then approx configuration file generated
    And approx restarted

