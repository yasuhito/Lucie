Feature: Installer Service

  As a Lucie installer
  I want to build installer
  So that I can start the first stage

  Scenario: Setup installer	 
    Given installers temporary directory "/tmp/installers" is empty
    And an installer for suite "lenny"
    When I setup the installer
    Then the installer is built

