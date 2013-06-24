@hiera18
Feature: Decrypt values via hiera command

  Background: Encrypt key info
    Given a file named "bar.yaml.key" with:
    """
    ---
    password: secret
    recipients:
      - test@example.com
    """
    And I run `raziel key:encrypt bar`
    And a file named "config.yaml" with:
    """
    ---
    #
    # Hiera does not like TABs. Please keep this in mind.
    #
    :backends:
      - yamlenc
      - yaml
    
    :logger: console
    
    :hierarchy:
      - bar
    
    :yaml:
       :datadir: ./
    
    :yamlenc:
       :datadir: ./
    """

  Scenario: Decrypt normal value
    Given a file named "bar.yaml.plain" with:
    """
    ---
    somekey: somevalue
    """
    When I run `raziel encrypt bar`
    Then the exit status should be 0
    When I remove the file "bar.yaml.plain"
    And I run `hiera1.8 --config config.yaml somekey`
    Then the exit status should be 0
    And the output should contain "somevalue"

  Scenario: Decrypt encryted value
    Given a file named "bar.yaml.plain" with:
    """
    ---
    somekey: PLAIN(secret)
    """
    When I run `raziel encrypt bar`
    Then the exit status should be 0
    And the file "bar.yaml.enc" should not contain "PLAIN"
    When I remove the file "bar.yaml.plain"
    And I run `hiera1.8 --config config.yaml somekey`
    Then the exit status should be 0
    And the output should contain "secret"

  Scenario: Decrypt array value
    Given a file named "bar.yaml.plain" with:
    """
    ---
    somekey:
      - foo
      - PLAIN(geheim)
    """
    When I run `raziel encrypt bar`
    Then the exit status should be 0
    And the file "bar.yaml.enc" should not contain "PLAIN"
    When I remove the file "bar.yaml.plain"
    And I run `hiera1.8 --config config.yaml somekey`
    Then the exit status should be 0
    And the output should contain "geheim"

  Scenario: Decrypt hash value
    Given a file named "bar.yaml.plain" with:
    """
    ---
    somekey:
      foo: PLAIN(secure)
      bar: somethingelse
    """
    When I run `raziel encrypt bar`
    Then the exit status should be 0
    And the file "bar.yaml.enc" should not contain "PLAIN"
    When I remove the file "bar.yaml.plain"
    And I run `hiera1.8 --config config.yaml somekey`
    Then the exit status should be 0
    And the output should contain "secure"

  Scenario: Decrypt multi line value
    Given a file named "bar.yaml.plain" with:
    """
    ---
    somekey: |
      PLAIN(-----BEGIN RSA PRIVATE KEY-----
      1234567890qwerty
      -----END RSA PRIVATE KEY-----)
    """
    When I run `raziel encrypt bar`
    Then the exit status should be 0
    And the file "bar.yaml.enc" should not contain "PLAIN"
    When I remove the file "bar.yaml.plain"
    And I run `hiera1.8 --config config.yaml somekey`
    Then the exit status should be 0
    And the output should contain "KEY-----\n1234567890qwerty\n-----END"
