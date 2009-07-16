Feature: Installer Service

  As a Lucie installer
  I want to build installer
  So that I can start first stage

  Scenario: Setup installer	 
    Given a node named "yutaro"
    And installers temporary directory "/tmp/lucie/tmp/installers" is empty
    And an installer for suite "lenny"
    When I setup installer
    Then installer built

