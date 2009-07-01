Feature: check prerequisites
  As a Lucie user
  I want to make Lucie check prerequisites
  So that I can make sure all requires softwares are installed

  Scenario: check prerequisites (success)
    Given --dry-run option is on
    When I try to check prerequisites
    Then "syslinux" checked
    And "tftpd-hpa" checked
    And "nfs-kernel-server" checked
    And "dhcp3-server" checked
    And "approx" checked
    And "debootstrap" checked
