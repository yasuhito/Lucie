Feature: boot sequence tracker tracks reboot process

  As a super-reboot module
  I want to track reboot process with boot sequence tracker
  So that I could make a precise reboot log and a better error handling

  Background:
    Given a node named "yutaro", with IP address "192.168.0.1" and with MAC address "11:22:33:44:55:66"

  Scenario: wait until PXE boot
    Given boot sequence tracker started for node "yutaro"
    When I try to wait until node "yutaro" boots with PXE
    Then "Waiting for yutaro to request PXE boot loader ..." displayed
    Then "Waiting for yutaro to request PXE boot loader configuration file ..." displayed
    Then "Waiting for yutaro to request Lucie kernel ..." displayed

  Scenario: wait until PXE local boot
    Given boot sequence tracker started for node "yutaro"
    When I try to wait until node "yutaro" boots from local hard disk with PXE
    Then "Waiting for yutaro to request PXE boot loader ..." displayed
    Then "Waiting for yutaro to request PXE boot loader configuration file ..." displayed

  Scenario: wait until DHCPACK
    Given boot sequence tracker started for node "yutaro"
    When I try to wait until dhcpd sends DCHPACK to node "yutaro"
    Then "Waiting for yutaro to send DHCPDISCOVER ..." displayed
    Then "Waiting for yutaro to receive DHCPOFFER ..." displayed
    Then "Waiting for yutaro to send DHCPREQUEST ..." displayed
    Then "Waiting for yutaro to receive DHCPACK ..." displayed

  Scenario: wait until nfsroot mount
    Given boot sequence tracker started for node "yutaro"
    When I try to wait until nfsroot mounted from node "yutaro"
    Then "Waiting for yutaro to mount nfsroot ..." displayed

  Scenario: wait until remote node responds to ping
    Given boot sequence tracker started for node "yutaro"
    When I try to wait until node responds to ping
    Then "Waiting for yutaro to respond to ping ..." displayed

  Scenario: wait until remote node not responds to ping
    Given boot sequence tracker started for node "yutaro"
    When I try to wait until node not responds to ping
    Then "Waiting for yutaro to stop responding to ping ..." displayed

  Scenario: wait until sshd is up
    Given boot sequence tracker started for node "yutaro"
    When I try to wait until sshd is up
    Then "Waiting for yutaro to start sshd ..." displayed
