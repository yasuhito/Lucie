Feature: generate ssh keypair

  As a Lucie install command
  I want to generage ssh keypair
  So that users don't have to generate keypair by hand

  Scenario: generate ssh keypair
    Given ssh home directory "/tmp/ssh" is empty
    When I try to generate ssh keypair
    Then ssh keypair generated

  Scenario: don't generate ssh keypair if already exists
    And ssh keypair already generated in ssh home directory "/tmp/ssh"
    When I try to generate ssh keypair
    Then ssh keypair not generated
