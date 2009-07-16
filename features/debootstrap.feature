Feature: debootstrap

  As a Lucie installer
  I want to call debootstrap command
  So that I can build nfsroot

  Scenario: debootstrap version
    Given debootstrap installed
    When I try to get debootstrap version
    Then I can get debootstrap version

  Scenario: fail to determine debootstrap version
    Given debootstrap not installed
    When I try to get debootstrap version
    Then I cannot get debootstrap version

  Scenario: start debootstrap
    Given suite is "lenny"
    And target is "/tmp/debootstrap"
    And package repository is "http://debian.repository/debian"
    And exclude is "vim, xeyes"
    And include is "emacs23, sl"
    When I try to start debootstrap
    Then debootstrap command "/usr/sbin/debootstrap --verbose --exclude=vim,xeyes --include=emacs23,sl lenny /tmp/debootstrap http://debian.repository/debian" executed

  Scenario: start debootstrap with arch option
    Given architecture is "amd64"
    And suite is "lenny"
    And target is "/tmp/debootstrap"
    And package repository is "http://debian.repository/debian"
    And exclude is "vim, xeyes"
    And include is "emacs23, sl"
    When I try to start debootstrap
    Then debootstrap command "/usr/sbin/debootstrap --arch amd64 --verbose --exclude=vim,xeyes --include=emacs23,sl lenny /tmp/debootstrap http://debian.repository/debian" executed

  Scenario: start debootstrap with http_proxy
    Given suite is "lenny"
    And target is "/tmp/debootstrap"
    And package repository is "http://debian.repository/debian"
    And exclude is "vim, xeyes"
    And include is "emacs23, sl"
    And http proxy is "http://myproxy:3128/"
    When I try to start debootstrap
    Then debootstrap command "/usr/sbin/debootstrap --verbose --exclude=vim,xeyes --include=emacs23,sl lenny /tmp/debootstrap http://debian.repository/debian (http_proxy = http://myproxy:3128/)" executed

  Scenario: fail to debootstrap (suite option not set)
    Given suite is not set
    And target is "/tmp/debootstrap"
    And package repository is "http://debian.repository/debian"
    When I try to start debootstrap
    Then I should get debootstrap error "suite option is a mandatory"

  Scenario: fail to debootstrap (target option not set)
    Given suite is "lenny"
    And target is not set
    And package repository is "http://debian.repository/debian"
    When I try to start debootstrap
    Then I should get debootstrap error "target option is a mandatory"

  Scenario: fail to debootstrap (package_repository option not set)
    Given suite is "lenny"
    And target is "/tmp/debootstrap"
    And package repository is not set
    When I try to start debootstrap
    Then I should get debootstrap error "package_repository option is a mandatory"
