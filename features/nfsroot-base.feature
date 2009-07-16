Feature: nfsroot base builder

  As a Lucie installer
  I want to cache debootstrap result as nfsroot base tarball
  So that I can speed up installation time

  Background:
    Given the rake task list cleared
    And installers temporary directory "/tmp/installers" is empty

  Scenario: build nfsroot base
    Given suite is "potato"
    And architecture is "amd64"
    When I try to build nfsroot base
    Then nfsroot base tarball created on "/tmp/installers/potato_amd64.tgz"
