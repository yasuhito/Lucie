Feature: nfsroot builder
  As a Lucie user
  I want to setup nfsroot automatically
  So that I can install nodes using the nfsroot

  Background:
    Given Lucie log path is "/tmp/lucie.log"
    And the rake task list cleared

  Scenario: build nfsroot base
    Given nfsroot target directory is "/tmp/nfsroot"
    And suite is "potato"
    And package repository is "http://myrepos/debian"
    And kernel package is "linux-image-2.6.18-fai-kernels_1_i386.deb"
    And kernel version is "2.6.18-fai-kernels"
    When I try to build nfsroot
    Then nfsroot created on "/tmp/nfsroot"

