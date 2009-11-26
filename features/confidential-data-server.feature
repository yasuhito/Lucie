Feature: Confidential Data Server

  As a configuration script
  I want to get confidential data from confidential data server
  So that I can safely inject confidential data into nodes

  Scenario: get confidential data
    Given an encrypted file with contents "himitsu" (password = "alpine")
    And a confidential data server started with the encrypted file
    When I try to connect to the server
    Then I get a decrypted string "himitsu" from the server
