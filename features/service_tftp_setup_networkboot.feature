Feature: Setup tftpd for network boot

  As a Lucie user
  I want Lucie to automatically configure tftpd for network boot
  So that I don't have to write tftpd configuration by hand

  Background:
    Given tftp root path is "/tmp/tftp_root"
    And installers temporary directory "/tmp/lucie/tmp/installers" is empty
    And an installer for suite "lenny"

  Scenario: Setup tftpd
    Given a node named "yasuhito_private_node00" with MAC address "00:00:00:00:00:00"
    And a node named "yasuhito_private_node01" with MAC address "11:11:11:11:11:11"
    And a node named "yasuhito_private_node02" with MAC address "22:22:22:22:22:22"
    When I try to setup tftpd nfsroot with installer "lenny_i386"
    Then PXE directory should be created
    And PXE configuration file for node "yasuhito_private_node00" should be generated
    And PXE configuration file for node "yasuhito_private_node01" should be generated
    And PXE configuration file for node "yasuhito_private_node02" should be generated

  Scenario Outline: Tftpd auto reload configuration
    Given RUN_DAEMON option of tftpd default config is "<RUN_DAEMON>"
    And command line option of default config is "<tftpd option>"
    And a node named "yasuhito_private_node00" with MAC address "00:00:00:00:00:00"
    When I try to setup tftpd nfsroot with installer "lenny_i386"
    Then "tftpd config generated?" is "<config generated?>"

  Scenarios:
    | RUN_DAEMON | tftpd option               | config generated? |
    | YES        | -v -l -s /foo/bar          | YES               |
    | NO         | -v -l -s /foo/bar          | YES               |
    | NO         | -v -l -s /var/lib/tftpboot | YES               |
    | YES        | -v -l -s /var/lib/tftpboot | NO                |

  Scenario Outline: Reconfigure and restart inetd
    Given RUN_DAEMON option of tftpd default config is "YES"
    And command line option of default config is "-v -l -s /var/lib/tftpboot"
    And "inetd.conf has tftpd entry?" is "<inetd.conf has tftpd entry?>"
    And a node named "yasuhito_private_node00" with MAC address "00:00:00:00:00:00"
    When I try to setup tftpd nfsroot with installer "lenny_i386"
    Then "inetd.conf updated?" is "<inetd.conf updated?>"
    And "inetd restarted?" is "<inetd restarted?>"

  Scenarios:
    | inetd.conf has tftpd entry? | inetd.conf updated? | inetd restarted? |
    | YES                         | YES                 | YES              |
    | NO                          | NO                  | NO               |

  Scenario: Setup tftpd with no node
    Given RUN_DAEMON option of tftpd default config is "NO"
    And command line option of default config is "-v -l -s /var/lib/tftpboot"
    When I try to setup tftpd nfsroot with installer "lenny_i386"
    Then tftpd is not restarted
    And "tftpd config generated?" is "NO"
