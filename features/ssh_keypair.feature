Feature: generate ssh keypair

  As a Lucie install command
  I want to generage ssh keypair and append public key to authorized_keys
  So that users don't have to do that by hand

  Scenario: generate ssh keypair
    Given ssh home directory "/tmp/ssh" is empty
    When I try to generate ssh keypair
    Then ssh keypair generated

  Scenario: don't generate ssh keypair if already exists
    Given ssh home directory "/tmp/ssh" is empty
    And ssh keypair already generated
    When I try to generate ssh keypair
    Then ssh keypair not generated

  Scenario: cp public key to authorized_keys
    Given ssh home directory "/tmp/ssh" is empty
    And authorized_keys does not exist
    When I try to generate ssh keypair
    Then generated public key copied to authorized_keys

  Scenario: append public key to autherized_keys
    Given ssh home directory "/tmp/ssh" is empty
    And empty authorized_keys already exists
    When I try to generate ssh keypair
    Then generated public key appended to authorized_keys

