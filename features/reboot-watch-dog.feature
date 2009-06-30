Feature: reboot-watchdog tracks reboot process

  As a super-reboot module
  I want to track reboot process with reboot-watchdog
  So that I could make a precise reboot log and a better error handling

  Background:
    Given a node named "yutaro", with IP address "192.168.0.1" and with MAC address "11:22:33:44:55:66"

  Scenario: wait until PXE boot
    Given --dry-run option is on
    And reboot-watchdog started for node "yutaro"
    When I try to wait until node "yutaro" boots with PXE
    Then "waiting for yutaro to request PXE boot loader ..." displayed
    Then "waiting for yutaro to request PXE boot loader configuration file ..." displayed
    Then "waiting for yutaro to request Lucie kernel ..." displayed

  Scenario: wait until PXE local boot
    Given --dry-run option is on
    And reboot-watchdog started for node "yutaro"
    When I try to wait until node "yutaro" boots from local hard disk with PXE
    Then "waiting for yutaro to request PXE boot loader ..." displayed
    Then "waiting for yutaro to request PXE boot loader configuration file ..." displayed

  Scenario: wait until DHCPACK
    Given --dry-run option is on
    And reboot-watchdog started for node "yutaro"
    When I try to wait until dhcpd sends DCHPACK to node "yutaro"
    Then "waiting for yutaro to send DHCPDISCOVER ..." displayed
    Then "waiting for yutaro to receive DHCPOFFER ..." displayed
    Then "waiting for yutaro to send DHCPREQUEST ..." displayed
    Then "waiting for yutaro to receive DHCPACK ..." displayed

  Scenario: wait until nfsroot mount
    Given --dry-run option is on
    And reboot-watchdog started for node "yutaro"
    When I try to wait until nfsroot mounted from node "yutaro"
    Then "waiting for yutaro to mount nfsroot ..." displayed

  Scenario: wait until remote node responds to ping
    Given --dry-run option is on
    And reboot-watchdog started for node "yutaro"
    When I try to wait until node responds to ping
    Then "waiting for yutaro to respond to ping ..." displayed

  Scenario: wait until remote node not responds to ping
    Given --dry-run option is on
    And reboot-watchdog started for node "yutaro"
    When I try to wait until node not responds to ping
    Then "waiting for yutaro to stop responding to ping ..." displayed

  Scenario: wait until sshd is up
    Given --dry-run option is on
    And reboot-watchdog started for node "yutaro"
    When I try to wait until sshd is up
    Then "waiting for sshd to start on yutaro ..." displayed
