Feature: Confidential Data Server

  As a configuration script
  I want to get confidential data such as private keys and passwords from lucie server using SSH
  So that I can configure them safely

  Scenario: get confidential data
    Given confidential data server holds confidential data "himitsu"
    When I connect to the confidential data server
    Then I get "himitsu" from the confidential data server
