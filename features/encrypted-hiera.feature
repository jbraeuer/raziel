Feature: Encrypt information about encryption

  Background: Encrypt key info
    Given a file named "bar.yaml.key" with:
    """
    ---
    password: secret
    recipients:
      - test@example.com
    """
    And I run `raziel key:encrypt bar`

  Scenario: leave normal hiera data untouched during encryption
    Given a file named "bar.yaml.plain" with:
    """
    ---
    somekey: somevalue
    """
    When I run `raziel encrypt bar`
    Then the exit status should be 0
    And the file "bar.yaml.enc" should contain:
    """
    ---
    somekey: somevalue
    """

  Scenario: leave normal hiera data untouched during decryption
    Given a file named "bar.yaml.plain" with:
    """
    ---
    somekey: somevalue
    """
    When I run `raziel encrypt bar`
    And I remove the file "bar.yaml.plain"
    And I run `raziel decrypt bar`
    Then the exit status should be 0
    And the file "bar.yaml.plain" should contain:
    """
    ---
    somekey: somevalue
    """

  Scenario: Encrypt data marked with PLAIN()
    Given a file named "bar.yaml.plain" with:
    """
    ---
    passwd: PLAIN(secret)
    """
    When I run `raziel encrypt bar`
    Then the exit status should be 0
    And the file "bar.yaml.enc" should not contain "PLAIN(secret)"
    And the file "bar.yaml.enc" should not contain "ENC(secret)"
    # base64 encoding of 'secret'
    And the file "bar.yaml.enc" should not contain "ENC(c2VjcmV0)"

  Scenario: Decrypt just encrypted data.
    Given a file named "bar.yaml.plain" with:
    """
    ---
    key: PLAIN(important)
    """
    When I run `raziel encrypt bar`
    And I remove the file "bar.yaml.plain"
    And I run `raziel decrypt bar`
    Then the exit status should be 0
    And the file "bar.yaml.plain" should contain:
    """
    ---
    key: PLAIN(important)
    """

  Scenario: Multiline value
    Given a file named "bar.yaml.plain" with:
    """
    ---
    key: |
      PLAIN(
      line1
      line2
      )
    """
    When I run `raziel encrypt bar`
    Then the file "bar.yaml.enc" should not contain "PLAIN"
    And the file "bar.yaml.enc" should contain "ENC("
    And the file "bar.yaml.enc" should contain ")"
    When I remove the file "bar.yaml.plain"
    And I run `raziel decrypt bar`
    Then the exit status should be 0
    And the file "bar.yaml.plain" should contain:
    """
    ---
    key: |-
      PLAIN(
      line1
      line2
      )
    """

  Scenario: Encrypt deeper levels
    Given a file named "bar.yaml.plain" with:
    """
    ---
    foo:
      - bar: PLAIN(secret)
        yet: PLAIN(another)
    bar:
      this: PLAIN(works too)
    """
    When I run `raziel encrypt bar`
    Then the exit status should be 0
    And the file "bar.yaml.enc" should not contain "PLAIN"
    And the file "bar.yaml.enc" should not contain "secret"
    # base64 encoding of 'secret'
    And the file "bar.yaml.enc" should not contain "c2VjcmV0"
    And the file "bar.yaml.enc" should contain "ENC"
