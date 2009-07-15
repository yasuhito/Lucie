Feature: generate ssh keypair

  As a Lucie install command
  I want to generage ssh keypair if not found
  So that users don't have to generate by hand

  Scenario: generate ssh keypair
    Given ssh home directory "/tmp/ssh" is empty
    When I try to generate ssh keypair
    Then ssh keypair generated
