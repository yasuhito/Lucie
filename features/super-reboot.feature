Feature: super-reboot reboots nodes

  As a node install(-multi) command
  I want to reboot nodes
  So that I can finish installations

  Background:
    Given a node named "yutaro", with IP address "192.168.0.1" and with MAC address "11:22:33:44:55:66"
    And html logger started

  Scenario: start first stage with reboot-script and succeed
    Given reboot script "/tmp/reboot.sh"
    When I start first stage of node "yutaro"
    Then "Executing '/tmp/reboot.sh yutaro' to reboot yutaro ..." displayed
    And "Succeeded in executing '/tmp/reboot.sh yutaro'. Now rebooting yutaro ..." displayed

  Scenario: start first stage with ssh and succeed
    When I start first stage of node "yutaro"
    Then "Rebooting yutaro via ssh ..." displayed
    And "Succeeded in rebooting yutaro via ssh. Now rebooting ..." displayed

  Scenario: start second stage and succeed
    When I start second stage of node "yutaro"
    Then "Rebooting yutaro via ssh ..." displayed

