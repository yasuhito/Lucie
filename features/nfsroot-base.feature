Feature: nfsroot base builder
  As a Lucie user
  I want to cache debootstrap result as nfsroot base tarball
  So that I can speed up installation time

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And installers temporary directory "/tmp/installers" is empty
    And the rake task list cleared

  Scenario: build nfsroot base
    Given suite is "potato"
    When I try to build nfsroot base
    Then nfsroot base tarball created on "/tmp/installers/potato.tgz"

