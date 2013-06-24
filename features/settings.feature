Feature: Encrypt information about encryption

  Scenario: Can't find key file for encryption
    When I run `raziel key:encrypt foo`
    Then the output should contain "No such file or directory - foo.yaml.key"
    Then the exit status should be 1

  Scenario: Encrypt key info
    Given a file named "foo.yaml.key" with:
    """
    ---
    password: secret
    recipients:
      - test@example.com
    """
    When I run `raziel key:encrypt foo`
    Then the exit status should be 0
    And a file named "foo.yaml.key.asc" should exist
    And the file named "foo.yaml.key.asc" is a binary file

  Scenario: decrypt the encrypted key file
    Given a file named "foo.yaml.key" with:
    """
    ---
    password: secret
    recipients:
      - test@example.com
    """
    When I run `raziel key:encrypt foo`
    And I remove the file "foo.yaml.key"
    And I run `raziel key:decrypt foo` interactively
    And I enter my password
    Then the exit status should be 0
    And the file "foo.yaml.key" should contain:
    """
    ---
    password: secret
    recipients:
      - test@example.com
    """
