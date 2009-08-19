Feature: check prerequisites

  As a Lucie installer
  I want to make sure that all required software packages are installed
  So that I can start installation successfully

  Scenario: Check prerequisites and succeed
    When I try to check prerequisites
    Then "syslinux" checked
    And "tftpd-hpa" checked
    And "nfs-kernel-server" checked
    And "dhcp3-server" checked
    And "approx" checked
    And "debootstrap" checked

  Scenario: Check prerequisites and fail
    Given new service "GalacticPizzaDelivery", with prerequisite "spaceship"
    When I try to check prerequisites
    Then "Checking spaceship ... NOT INSTALLED" displayed
