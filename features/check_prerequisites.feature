Feature: check prerequisites

  As a Lucie installer
  I want to make sure that all required software packages are installed
  So that I can start installation successfully

  Scenario: Check prerequisites and succeed
    Given --verbose option is on
    When I try to check prerequisites
    Then "syslinux" checked
    And "tftpd-hpa" checked
    And "nfs-kernel-server" checked
    And "dhcp3-server" checked
    And "approx" checked
    And "debootstrap" checked

  Scenario: Check prerequisites and succeed
    Given --verbose option is off
    When I try to check prerequisites
    Then nothing displayed

  Scenario: Check prerequisites and fail
    Given --verbose option is on
    And new service "GalacticPizzaDelivery", with prerequisite "spaceship"
    When I try to check prerequisites
    Then "Checking spaceship ... not installed" displayed
