Feature: Secret Server

  As a configuration script
  I want to get confidential data such as private keys and passwords from lucie server using SSH
  So that I can configure them safely

  Scenario: get secret data from lucie server
    Given secret server holds confidential data "himitsu"
    When I connect to secret server
    Then I get "himitsu" from secret server
