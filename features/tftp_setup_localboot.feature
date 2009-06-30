Feature: Setup tftpd to boot from local disks
  As a Lucie user
  I want to setup tftp localboot automatically
  So that I have not to write configuration and restart tftpd by hand

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And node list is empty
  
  Scenario: Setup tftpd
    Given RUN_DAEMON option of tftpd default config is "YES"
    And command line option of default config is "-v -l -s /var/lib/tftpboot"
    And a node named "yasuhito_private_node00", with IP address "192.168.0.100"
    And a node named "yasuhito_private_node01", with IP address "192.168.0.101"
    And a node named "yasuhito_private_node02", with IP address "192.168.0.102"
    When I try to setup tftpd localboot for node "yasuhito_private_node01"
    Then PXE configuration file for node "yasuhito_private_node01" should be modified to boot from local

  Scenario Outline: Tftpd auto reload configuration
    Given RUN_DAEMON option of tftpd default config is "<RUN_DAEMON>"
    And command line option of default config is "<tftpd option>"
    And a node named "yasuhito_private_node00", with IP address "192.168.0.100"
    When I try to setup tftpd localboot for node "yasuhito_private_node00"
    Then "tftpd config generated?" is "<config generated?>"
    And "tftpd restarted?" is "<tftpd restarted?>"

  Scenarios:
    | RUN_DAEMON | tftpd option            | config generated? | tftpd restarted? |
    | YES        | -v -l -s /foo/bar          | YES               | YES              |
    | NO         | -v -l -s /foo/bar          | YES               | YES              |
    | NO         | -v -l -s /var/lib/tftpboot | YES               | YES              |
    | YES        | -v -l -s /var/lib/tftpboot | NO                | NO               |

  Scenario Outline: Reconfigure and restart inetd
    Given RUN_DAEMON option of tftpd default config is "YES"
    And command line option of default config is "-v -l -s /var/lib/tftpboot"
    And "inetd.conf has tftpd entry?" is "<inetd.conf has tftpd entry?>"
    And a node named "yasuhito_private_node00", with IP address "192.168.0.100"
    When I try to setup tftpd localboot for node "yasuhito_private_node00"
    Then "inetd.conf updated?" is "<inetd.conf updated?>"
    And "inetd restarted?" is "<inetd restarted?>"
    And "tftpd restarted?" is "<tftpd restarted?>"

  Scenarios:
    | inetd.conf has tftpd entry? | inetd.conf updated? | inetd restarted? | tftpd restarted? |
    | YES                         | YES                 | YES              | YES              |
    | NO                          | NO                  | NO               | NO               |
