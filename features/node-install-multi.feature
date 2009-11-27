Feature: node install-multi command

  As a Lucie user
  I want to install nodes with node install-multi command
  So that I can install multiple nodes

  Background:
    Given eth0 "192.168.0.1"

  Scenario: node install-multi
    Given install option for node "yasuhito_node0" is "--ip-address 192.168.0.100 --mac 11:22:33:44:55:00 --storage-conf storage0.conf"
    And install option for node "yasuhito_node1" is "--ip-address 192.168.0.101 --mac 11:22:33:44:55:11 --storage-conf storage1.conf"
    And install option for node "yasuhito_node2" is "--ip-address 192.168.0.102 --mac 11:22:33:44:55:22 --storage-conf storage2.conf"
    When I try to run 'node install-multi', with option "--netmask 255.255.255.0 --ldb-repository http://myrepository.com/ldb", and nodes "yasuhito_node0, yasuhito_node1, yasuhito_node2"
    Then nodes "yasuhito_node0, yasuhito_node1, yasuhito_node2" installed

  Scenario: node local --storage-conf option
    Given install option for node "yasuhito_node0" is "--ip-address 192.168.0.100 --mac 11:22:33:44:55:00 --storage-conf storage0.conf"
    And install option for node "yasuhito_node1" is "--ip-address 192.168.0.101 --mac 11:22:33:44:55:11"
    And install option for node "yasuhito_node2" is "--ip-address 192.168.0.102 -mac 11:22:33:44:55:22 --storage-conf storage2.conf"
    When I try to run 'node install-multi', with option "--storage-conf global_storage.conf --netmask 255.255.255.0 --ldb-repository http://myrepository.com/ldb", and nodes "yasuhito_node0, yasuhito_node1, yasuhito_node2"
    Then nodes "yasuhito_node0" installed using storage conf "storage0.conf"
    Then nodes "yasuhito_node1" installed using storage conf "global_storage.conf"
    Then nodes "yasuhito_node2" installed using storage conf "storage2.conf"

  Scenario: global --storage-conf option
    Given install option for node "yasuhito_node0" is "--ip-address 192.168.0.100 --mac 11:22:33:44:55:00"
    And install option for node "yasuhito_node1" is "--ip-address 192.168.0.101 --mac 11:22:33:44:55:11"
    And install option for node "yasuhito_node2" is "--ip-address 192.168.0.102 --mac 11:22:33:44:55:22"
    When I try to run 'node install-multi', with option "--storage-conf global_storage.conf --netmask 255.255.255.0 --ldb-repository http://myrepository.com/ldb", and nodes "yasuhito_node0, yasuhito_node1, yasuhito_node2"
    Then nodes "yasuhito_node0, yasuhito_node1, yasuhito_node2" installed using storage conf "global_storage.conf"

  Scenario: check prerequisites
    Given install option for node "yasuhito_node0" is "--ip-address 192.168.0.100 --mac 11:22:33:44:55:00 --storage-conf storage0.conf"
    And install option for node "yasuhito_node1" is "--ip-address 192.168.0.101 --mac 11:22:33:44:55:11 --storage-conf storage1.conf"
    And install option for node "yasuhito_node2" is "--ip-address 192.168.0.102 --mac 11:22:33:44:55:22 --storage-conf storage2.conf"
    When I try to run 'node install-multi', with option "--netmask 255.255.255.0 --ldb-repository http://myrepository.com/ldb", and nodes "yasuhito_node0, yasuhito_node1, yasuhito_node2"
    Then "syslinux" checked
    And "tftpd-hpa" checked
    And "nfs-kernel-server" checked
    And "dhcp3-server" checked
    And "approx" checked
    And "debootstrap" checked
